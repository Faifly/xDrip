//
//  DexcomG6BluetoothService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import CoreBluetooth
import AKUtils

final class DexcomG6BluetoothService: NSObject {
    private weak var delegate: CGMBluetoothServiceDelegate?
    private let centralManager = CBCentralManager()
    private var isConnectionRequested = false
    private var centralManagerLastState: CBManagerState?
    private var messageWorker: DexcomG6MessageWorker?
    
    private var characteristics: [DexcomG6CharacteristicType: CBCharacteristic] = [:]
    private var peripheral: CBPeripheral? {
        didSet {
            peripheral?.delegate = self
        }
    }
    private var lastRSSI: Double = 100.0
    
    private var lastPeripheralReadingDate: Date?
    private var hasRecentlyConnected: Bool {
        guard let lastConnectionDate = lastPeripheralReadingDate else { return false }
        let delay = Date().timeIntervalSince1970 - lastConnectionDate.timeIntervalSince1970
        return delay < DexcomG6Constants.minimumReconnectionDelay
    }
    
    override init() {
        super.init()
        centralManagerLastState = centralManager.state
        centralManager.delegate = self
        messageWorker = DexcomG6MessageWorker(delegate: self)
    }
    
    private func startConnectionFlow() {
        LogController.log(message: "[Dexcom G6] Starting connection flow...", type: .debug)
        if let existingPeripheral = retrieveExistingPeripheral() {
            peripheral = existingPeripheral
            LogController.log(
                message: "[Dexcom G6] Found existing peripheral, trying to connect...",
                type: .debug
            )
            centralManager.connect(existingPeripheral, options: nil)
        } else {
            LogController.log(
                message: "[Dexcom G6] No existing peripherals found, starting scanning...",
                type: .debug
            )
            let advertisementID = CBUUID(string: DexcomG6Constants.advertisementServiceID)
            centralManager.scanForPeripherals(withServices: [advertisementID], options: nil)
        }
    }
    
    private func retrieveExistingPeripheral() -> CBPeripheral? {
        let device = CGMDevice.current
        guard device.deviceType == .dexcomG6 else { return nil }
        guard let addressString = device.bluetoothID else { return nil }
        guard let addressID = UUID(uuidString: addressString) else { return nil }
        return centralManager.retrievePeripherals(withIdentifiers: [addressID]).first
    }
    
    private func sendOutcomingMessage(_ message: DexcomG6OutgoingMessage) {
        LogController.log(
            message: "[Dexcom G6] Sending message: %@...",
            type: .debug,
            message.data.hexEncodedString
        )
        guard let peripheral = peripheral else {
            LogController.log(message: "[Dexcom G6] No peripheral on sending message", type: .error)
            return
        }
        guard let characteristic = characteristics[message.characteristic] else {
            LogController.log(message: "[Dexcom G6] No write characteristic on sending message", type: .error)
            return
        }
        
        peripheral.writeValue(message.data, for: characteristic, type: .withResponse)
    }
}

extension DexcomG6BluetoothService: DexcomG6MessageWorkerDelegate {
    func workerRequiresSendingOutgoingMessage(_ message: DexcomG6OutgoingMessage) {
        sendOutcomingMessage(message)
    }
    
    func workerDidSuccessfullyAuthorize() {
        guard let peripheral = peripheral else { return }
        guard let writeCharacteristic = characteristics[.write] else { return }
        peripheral.setNotifyValue(true, for: writeCharacteristic)
        guard let backfillCharacteristic = characteristics[.backfill] else { return }
        peripheral.setNotifyValue(true, for: backfillCharacteristic)
    }
    
    func workerDidReceiveSensorData(_ message: DexcomG6SensorDataRxMessage) {
        lastPeripheralReadingDate = Date()
        LogController.log(
            message: "[Dexcom G6] Did receive reading with status: %u, filtered: %f, unfiltered: %f",
            type: .debug,
            message.status,
            message.filtered,
            message.unfiltered
        )
        let firmware = CGMDevice.current.metadata(ofType: .firmwareVersion)?.value
        delegate?.serviceDidReceiveSensorGlucoseReading(
            raw: DexcomG6Firmware.scaleRawValue(message.unfiltered, firmware: firmware),
            filtered: DexcomG6Firmware.scaleRawValue(message.filtered, firmware: firmware),
            rssi: lastRSSI
        )
        backFillIfNeeded()
    }
    
    func workerDidReceiveGlucoseData(_ message: DexcomG6GlucoseDataRxMessage) {
        delegate?.serviceDidReceiveGlucoseReading(calculatedValue: message.calculatedValue,
                                                  calibrationState: message.state,
                                                  date: Date(),
                                                  forBackfill: false)
        backFillIfNeeded()
    }
    
    func workerDidReceiveTransmitterInfo(_ message: DexcomG6TransmitterVersionRxMessage) {
        let firmwareVersion = message.firmwareVersion.map { "\(Int($0))" }.joined(separator: ".")
        LogController.log(
            message: "[Dexcom G6] Did receive transmitter info with firmware: %@",
            type: .debug,
            firmwareVersion
        )
        delegate?.serviceDidUpdateMetadata(.firmwareVersion, value: firmwareVersion)
    }
    
    func workerDidReceiveBatteryInfo(_ message: DexcomG6BatteryStatusRxMessage) {
        LogController.log(
            message: "[Dexcom G6] Received battery info voltage A: %d, B: %d, resist: %d, runtime: %d, temp: %d",
            type: .debug,
            message.voltageA,
            message.voltageB,
            message.resist,
            message.runtime,
            message.temperature
        )
        
        delegate?.serviceDidUpdateMetadata(.batteryVoltageA, value: "\(message.voltageA)")
        delegate?.serviceDidUpdateMetadata(.batteryVoltageB, value: "\(message.voltageB)")
        delegate?.serviceDidUpdateMetadata(.batteryRuntime, value: "\(message.runtime)")
        delegate?.serviceDidUpdateMetadata(.batteryResistance, value: "\(message.resist)")
        delegate?.serviceDidUpdateMetadata(.batteryTemperature, value: "\(message.temperature)")
    }
    
    func workerDidReceiveTransmitterTimeInfo(_ message: DexcomG6TransmitterTimeRxMessage) {
        LogController.log(message: "[Dexcom G6] Did receive transmitter time info: %f", type: .debug, message.age)
        delegate?.serviceDidUpdateMetadata(.transmitterTime, value: "\(message.age)")
    }
    
    func workerDidRequestPairing() {
        NotificationController.shared.sendNotification(ofType: .pairingRequest)
    }
    
    func workerDidReceiveGlucoseBackfillMessage(_ message: DexcomG6BackfillRxMessage) {
        LogController.log(
            message: "[Dexcom G6] Glucose backfill request is %@",
            type: .debug,
            message.valid ? "confirmed" : "corrupted"
        )
    }

    func workerDidReceiveBackfillData(_ backsies: [DexcomG6BackfillStream.Backsie]) {
        for backsie in backsies {
            let rawTime = backsie.dexTime
            guard let transmitterStartDate = CGMDevice.current.transmitterStartDate else {
                    return
            }
            let backsieDate = transmitterStartDate + Double(rawTime)
            let diff = Date().timeIntervalSince1970 - backsieDate.timeIntervalSince1970
            
            guard diff > 0, diff < TimeInterval.hours(6) else { return }
            
            delegate?.serviceDidReceiveGlucoseReading(calculatedValue: Double(backsie.glucose),
                                                      calibrationState: nil,
                                                      date: backsieDate,
                                                      forBackfill: true)
        }
    }
    
    func backFillIfNeeded() {
        let neededReadingsCount = Int(Constants.maxBackfillPeriod / Constants.dexcomPeriod)
        let earliestTimestamp = Date().timeIntervalSince1970 - Constants.maxBackfillPeriod
        let latestTimestamp = Date().timeIntervalSince1970
        let readings = GlucoseReading.readingsForInterval(
            DateInterval(start: Date() - Constants.maxBackfillPeriod - TimeInterval(minutes: 0.5),
                         end: Date() + TimeInterval(minutes: 0.5)))
        
        if readings.count < neededReadingsCount + 1 {
            guard let transmitterStartInterval = CGMDevice.current.transmitterStartDate?.timeIntervalSince1970 else {
                return
            }
            let startTime = Int(earliestTimestamp - TimeInterval(minutes: 5) - transmitterStartInterval)
            let endTime = Int(latestTimestamp + TimeInterval(minutes: 5) - transmitterStartInterval)
            messageWorker?.createBackFillRequest(startTime: startTime, endTime: endTime)
        }
    }
    
    func workerDidEncounterLatePairingAttempt() {
        delegate?.serviceDidFail(withError: .latePairingAttempt)
    }
    
    func workerDidReceiveCalibrateGlucoseData(_ message: DexcomG6CalibrationRxMessage) {
        if let calibration = Calibration.allForCurrentSensor.first,
           !calibration.isSentToTransmitter {
            calibration.markCalibrationAsSentToTransmitter()
            LogController.log(
                message: "[Dexcom G6] Marked last calibration as sent to transmitter",
                type: .debug
            )
        }
        LogController.log(
            message: "[Dexcom G6] DexcomG6CalibrationRxMessage accepted : %@, calibrationResponseType : %@",
            type: .debug,
            message.accepted.description,
            message.type.debugDescription
        )
        delegate?.serviceDidReceiveCalibrationResponse(type: message.type)
    }
}

extension DexcomG6BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn where isConnectionRequested: startConnectionFlow()
        case .poweredOff where centralManagerLastState != .unknown:
            delegate?.serviceDidFail(withError: .bluetoothIsPoweredOff)
            
        case .unauthorized: delegate?.serviceDidFail(withError: .bluetoothIsUnauthorized)
        case .unsupported: delegate?.serviceDidFail(withError: .bluetoothUnsupported)
        case .poweredOff:
            if #available(iOS 13, *) {
                break
            } else {
                delegate?.serviceDidFail(withError: .bluetoothIsPoweredOff)
            }
            
        case .resetting, .unknown, .poweredOn: break
        @unknown default: break
        }
        
        centralManagerLastState = centralManager.state
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        LogController.log(
            message: "[Dexcom G6] Did discover a peripheral: %@, trying to connect...",
            type: .debug,
            peripheral
        )
        if let sensorName = CGMDevice.current.sensorName,
            peripheral.name?.lowercased() == sensorName.lowercased() {
            central.stopScan()
            self.peripheral = peripheral
            lastRSSI = RSSI.doubleValue
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard isConnectionRequested else { return }
        LogController.log(
            message: "[Dexcom G6] Did connect to peripheral, discovering services...",
            type: .debug
        )
        CGMDevice.current.updateBluetoothID(peripheral.identifier.uuidString)
        delegate?.serviceDidConnect(isPaired: messageWorker?.workerIsPaired() ?? true)
        delegate?.serviceDidUpdateMetadata(.deviceName, value: peripheral.name ?? "")
        let serviceUUID = CBUUID(string: DexcomG6Constants.serviceID)
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        LogController.log(
            message: "[Dexcom G6] Did fail to connect to peripheral with error: %@",
            type: .debug,
            error: error
        )
        if #available(iOS 13.4, *) {
            if let error = error, (error as NSError).code == CBError.Code.peerRemovedPairingInformation.rawValue {
                delegate?.serviceDidFail(withError: .peerRemovedPairingInformation)
            }
        }
        if hasRecentlyConnected {
            LogController.log(message: "[Dexcom G6] Has connected recently, retrying in 10 seconds", type: .debug)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                guard let self = self else { return }
                self.startConnectionFlow()
            }
        } else {
            LogController.log(message: "[Dexcom G6] Reconnecting...", type: .debug)
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        LogController.log(
            message: "[Dexcom G6] Did disconnect peripheral with error: %@",
            type: .debug,
            error: error
        )
        delegate?.serviceDidDisconnect(isPaired: messageWorker?.workerIsPaired() ?? true)
        if hasRecentlyConnected {
            LogController.log(
                message: "[Dexcom G6] Has connected recently, retrying in 10 seconds",
                type: .debug
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                guard let self = self else { return }
                guard self.isConnectionRequested else { return }
                self.startConnectionFlow()
            }
        } else {
            guard isConnectionRequested else { return }
            LogController.log(message: "[Dexcom G6] Reconnecting...", type: .debug)
            central.connect(peripheral, options: nil)
        }
    }
}

extension DexcomG6BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        LogController.log(message: "[Dexcom G6] Did discover services with error: %@", type: .debug, error: error)
        LogController.log(message: "[Dexcom G6] Discovering characteristics...", type: .debug)
        peripheral.services?.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        LogController.log(
            message: "[Dexcom G6] Did discover characteristics with error: %@",
            type: .debug,
            error: error
        )
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid.uuidString == DexcomG6Constants.notifyCharacteristicID {
                LogController.log(message: "[Dexcom G6] Found notify characteristic", type: .debug)
                characteristics[.notify] = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid.uuidString == DexcomG6Constants.writeCharacteristicID {
                LogController.log(message: "[Dexcom G6] Found write characteristic", type: .debug)
                characteristics[.write] = characteristic
            } else if characteristic.uuid.uuidString == DexcomG6Constants.backfillCharacteristicID {
                LogController.log(message: "[Dexcom G6] Found backfill characteristic", type: .debug)
                characteristics[.backfill] = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                    error: Error?) {
        LogController.log(
            message: "[Dexcom G6] Did update notification state with error: %@",
            type: .debug,
            error: error
        )
        if characteristic.uuid.uuidString == DexcomG6Constants.notifyCharacteristicID {
            messageWorker?.createDataRequest(ofType: .authRequestTx)
        } else {
            messageWorker?.requestRequiredData()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        LogController.log(
            message: "[Dexcom G6] Did update value for characteristic with error: %@",
            type: .debug,
            error: error
        )
        
        switch characteristic.uuid.uuidString {
        case DexcomG6Constants.backfillCharacteristicID:
            messageWorker?.handleBackfillStream(characteristic.value)
            return
        default: break
        }
        
        do {
            try messageWorker?.handleIncomingMessage(characteristic.value)
        } catch DexcomG6Error.notAuthenticated {
            self.peripheral = nil
            centralManager.cancelPeripheralConnection(peripheral)
            
            LogController.log(
                message: "[Dexcom G6] Connected to wrong peripheral, starting scanning for new one...",
                type: .debug
            )
            
            let advertisementID = CBUUID(string: DexcomG6Constants.advertisementServiceID)
            centralManager.scanForPeripherals(withServices: [advertisementID], options: nil)
        } catch {
            delegate?.serviceDidFail(
                withError: .deviceSpecific(error: error as? LocalizedError ?? CGMBluetoothServiceError.unknown)
            )
        }
    }
}

extension DexcomG6BluetoothService: CGMBluetoothService {
    convenience init(delegate: CGMBluetoothServiceDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    func connect() {
        isConnectionRequested = true
        if centralManager.state == .poweredOn {
            startConnectionFlow()
        }
    }
    
    func disconnect() {
        guard let peripheral = peripheral else { return }
        if peripheral.state == .connected {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        self.isConnectionRequested = false
        self.lastPeripheralReadingDate = nil
    }
}

//
//  DexcomG6BluetoothService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import CoreBluetooth

final class DexcomG6BluetoothService: NSObject {
    private weak var delegate: CGMBluetoothServiceDelegate?
    private let centralManager = CBCentralManager()
    private var isConnectionRequested = false
    private var messageWorker: DexcomG6MessageWorker?
    
    private var characteristics: [DexcomG6CharacteristicType: CBCharacteristic] = [:]
    private var peripheral: CBPeripheral? {
        didSet {
            peripheral?.delegate = self
        }
    }
    
    private var lastPeripheralReadingDate: Date?
    private var hasRecentlyConnected: Bool {
        guard let lastConnectionDate = lastPeripheralReadingDate else { return false }
        let delay = Date().timeIntervalSince1970 - lastConnectionDate.timeIntervalSince1970
        return delay < DexcomG6Constants.minimumReconnectionDelay
    }
    
    override init() {
        super.init()
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
    }
    
    func workerDidReceiveReading(_ message: DexcomG6SensorDataRxMessage) {
        lastPeripheralReadingDate = Date()
        LogController.log(
            message: "[Dexcom G6] Did receive reading with status: %u, filtered: %f, unfiltered: %f",
            type: .debug,
            message.status,
            message.filtered,
            message.unfiltered
        )
        delegate?.serviceDidReceiveGlucoseReading(
            raw: message.unfiltered * 34.0,
            filtered: message.filtered * 34.0
        )
    }
    
    func workerDidReceiveTransmitterInfo(_ message: DexcomG6TransmitterVersionRxMessage) {
        LogController.log(
            message: "[Dexcom G6] Did receive transmitter info with firmware: %d",
            type: .debug,
            message.firmwareVersion.hexEncodedString
        )
        delegate?.serviceDidUpdateMetadata(.firmwareVersion, value: message.firmwareVersion.hexEncodedString)
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
}

extension DexcomG6BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn where isConnectionRequested: startConnectionFlow()
        case .poweredOff: delegate?.serviceDidFail(withError: .bluetoothIsPoweredOff)
        case .unauthorized: delegate?.serviceDidFail(withError: .bluetoothIsUnauthorized)
        case .unsupported: delegate?.serviceDidFail(withError: .bluetoothUnsupported)
        case .resetting, .unknown, .poweredOn: break
        @unknown default: break
        }
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
        self.peripheral = peripheral
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()
        LogController.log(
            message: "[Dexcom G6] Did connect to peripheral, discovering services...",
            type: .debug
        )
        CGMDevice.current.updateBluetoothID(peripheral.identifier.uuidString)
        self.peripheral = peripheral
        let serviceUUID = CBUUID(string: DexcomG6Constants.serviceID)
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        LogController.log(
            message: "[Dexcom G6] Did fail to connect to peripheral with error: %@",
            type: .debug,
            error: error
        )
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
        if hasRecentlyConnected {
            LogController.log(
                message: "[Dexcom G6] Has connected recently, retrying in 10 seconds",
                type: .debug
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                guard let self = self else { return }
                self.startConnectionFlow()
            }
        } else {
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
        do {
            try messageWorker?.handleIncomingMessage(characteristic.value)
        } catch {
            delegate?.serviceDidFail(withError: .deviceSpecific(error: error))
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
    }
}

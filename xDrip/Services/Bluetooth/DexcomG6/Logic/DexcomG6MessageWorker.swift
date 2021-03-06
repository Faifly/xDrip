//
//  DexcomG6MessageWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class DexcomG6MessageWorker {
    private weak var delegate: DexcomG6MessageWorkerDelegate?
    
    private var isQueueAwaitingForResponse = false
    private var isCalibrationMessageAlreadyQueued = false
    private var isRestartMessageAlreadyQueued = false
    private var isStopSensorMessageAlreadyQueued = false
    private var messageQueue: [DexcomG6OutgoingMessage] = []
    private let messageFactory = DexcomG6MessageFactory()
    private var backFillStream = DexcomG6BackfillStream()
    private var isPaired = false {
        didSet {
            if isPaired {
                delegate?.workerDidSuccessfullyAuthorize()
            }
        }
    }
    
    private var applicationStateObserver: NSObjectProtocol?
    private var keepingAliveSinceDate: Date?
    
    init(delegate: DexcomG6MessageWorkerDelegate) {
        self.delegate = delegate
    }
    
    func workerIsPaired() -> Bool {
        return isPaired
    }
    
    func handleIncomingMessage(_ data: Data?) throws {
        guard let data = data else { return }
        LogController.log(message: "[Dexcom G6] Received message: %@", type: .debug, data.hexEncodedString)
        guard let opCode = DexcomG6OpCode(rawValue: data[0]) else { return }
        
        switch opCode {
        case .authRequestRx:
            let message = try DexcomG6AuthRequestRxMessage(data: data)
            try sendChallengeRequest(authResponse: message)
            
        case .authChallengeRx:
            let message = try DexcomG6AuthChallengeRxMessage(data: data)
            try handleAuthResponse(message)
            
        case .pairRequestRx:
            let message = try DexcomG6PairRequestRxMessage(data: data)
            try handlePairResponse(message)
            
        case .sensorDataRx:
            let message = try DexcomG6SensorDataRxMessage(data: data)
            delegate?.workerDidReceiveSensorData(message)
            
        case .batteryStatusRx:
            let message = try DexcomG6BatteryStatusRxMessage(data: data)
            delegate?.workerDidReceiveBatteryInfo(message)
            
        case .transmitterVersionRx:
            let message = try DexcomG6TransmitterVersionRxMessage(data: data)
            delegate?.workerDidReceiveTransmitterInfo(message)
            
        case .transmitterTimeRx:
            let message = try DexcomG6TransmitterTimeRxMessage(data: data)
            delegate?.workerDidReceiveTransmitterTimeInfo(message)
            
        case .glucoseBackfillRx:
            let message = try DexcomG6BackfillRxMessage(data: data)
            delegate?.workerDidReceiveGlucoseBackfillMessage(message)
        case .glucoseRx:
            let message = try DexcomG6GlucoseDataRxMessage(data: data)
            delegate?.workerDidReceiveGlucoseData(message)
        case .calibrateGlucoseRx:
            let message = try DexcomG6CalibrationRxMessage(data: data)
            handleCalibrationRxMessage(message)
        case .sessionStopRx:
            let message = try DexcomG6SessionStopRxMessage(data: data)
            handleSensorStopRxMessage(message)
        case .sessionStartRx:
            let _ = try DexcomG6SessionStartRxMessage(data: data)
        default: break
        }
        
        isQueueAwaitingForResponse = false
        trySendingMessageFromQueue()
    }
    
    func createSensorRestartRequest(withStop: Bool) {
        guard let transmitterStartDate = CGMDevice.current.transmitterStartDate else {
            LogController.log(
                message: "[Dexcom G6] Transmitter Start Date is nil",
                type: .debug
            )
            return
        }
        guard !isRestartMessageAlreadyQueued else {
            LogController.log(
                message: "[Dexcom G6] Restart has been already queued",
                type: .debug
            )
            return
        }

        isRestartMessageAlreadyQueued = true
        
        var when = Date().timeIntervalSince1970
        var whenStarted = when
        
        if withStop {
            when -= (TimeInterval(hours: 2) + TimeInterval(minutes: 10))
            whenStarted += 1
            let stopMessage = DexcomG6SessionStopTxMessage(stopTime: Int(when  - transmitterStartDate.timeIntervalSince1970))
            messageQueue.append(stopMessage)
            trySendingMessageFromQueue()
        }
        
        let startMessage = DexcomG6SessionStartTxMessage(startTime: Int(when),
                                                         dexTime: Int(whenStarted - transmitterStartDate.timeIntervalSince1970))
        messageQueue.append(startMessage)
        trySendingMessageFromQueue()
    }

    func createDataRequest(ofType type: DexcomG6OpCode) {
        guard isPaired || !type.requiresPairing else { return }
        guard let message = messageFactory.createOutgoingMessage(ofType: type) else { return }
        if type == .authRequestTx {
            isQueueAwaitingForResponse = false
            isCalibrationMessageAlreadyQueued = false
            isRestartMessageAlreadyQueued = false
            isStopSensorMessageAlreadyQueued = false
            messageQueue.removeAll()
        }
        messageQueue.append(message)
        trySendingMessageFromQueue()
    }
    
    func requestRequiredData() {
        guard !CGMDevice.current.isResetScheduled else {
            requestReset()
            return
        }
        
        if CGMDevice.current.requiresUpdate(for: .firmwareVersion) {
            LogController.log(message: "[Dexcom G6] Firmware version update required", type: .debug)
            createDataRequest(ofType: .transmitterVersionTx)
        }
        if CGMDevice.current.requiresUpdate(for: .batteryVoltageA) {
            LogController.log(message: "[Dexcom G6] Battery status update required", type: .debug)
            createDataRequest(ofType: .batteryStatusTx)
        }
        if CGMDevice.current.requiresUpdate(for: .transmitterTime) {
            LogController.log(message: "[Dexcom G6] Transmitter time update required", type: .debug)
            createDataRequest(ofType: .transmitterTimeTx)
        }
        
        guard let firstVersionCharacter = CGMDevice.current.transmitterVersionString?.first,
              let transmitterVersion = DexcomG6FirmwareVersion(rawValue: firstVersionCharacter) else {
            LogController.log(message: "[Dexcom G6] Could not resolve transmitter version", type: .debug)
            return
        }
        
        if transmitterVersion == .first {
            createDataRequest(ofType: .sensorDataTx)
        } else if transmitterVersion == .second {
            createCalibrationRequest()
            createDataRequest(ofType: .glucoseTx)
            createStopSensorRequest()
        }
    }
    
    func requestReset() {
        CGMDevice.current.requireAllMetadataUpdate()
        CGMDevice.current.scheduleReset(false)
        createDataRequest(ofType: .resetTx)
    }
    
    private func sendChallengeRequest(authResponse: DexcomG6AuthRequestRxMessage) throws {
        isPaired = false
        guard let serial = CGMDevice.current.metadata(ofType: .serialNumber)?.value else { return }
        let message = try DexcomG6AuthChallengeTxMessage(challenge: authResponse.challenge, serial: serial)
        delegate?.workerRequiresSendingOutgoingMessage(message)
    }
    
    private func handleAuthResponse(_ response: DexcomG6AuthChallengeRxMessage) throws {
        guard response.authenticated else { throw DexcomG6Error.notAuthenticated }
        if response.paired {
            isPaired = true
        } else {
            LogController.log(
                message: "[Dexcom G6] Not paired, requesting user and keeping alive...",
                type: .debug
            )
            createDataRequest(ofType: .keepAliveTx)
            delegate?.workerDidRequestPairing()
            keepingAliveSinceDate = Date()
            
            if UIApplication.shared.applicationState == .active {
                createDataRequest(ofType: .pairRequestTx)
            } else {
                subscribeForPairingApplicationState()
            }
        }
    }
    
    private func subscribeForPairingApplicationState() {
        guard applicationStateObserver == nil else { return }
        
        applicationStateObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: nil) { [weak self] _ in
            guard let self = self else { return }
            guard !self.isPaired else { return }
            guard let keep = self.keepingAliveSinceDate?.timeIntervalSince1970 else { return }
            self.keepingAliveSinceDate = nil
            guard (Date().timeIntervalSince1970 - keep) <= Double(CGMDeviceType.dexcomG6.keepAliveSeconds) else {
                self.delegate?.workerDidEncounterLatePairingAttempt()
                return
            }
            self.createDataRequest(ofType: .pairRequestTx)
            
            guard let observer = self.applicationStateObserver else { return }
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func handlePairResponse(_ response: DexcomG6PairRequestRxMessage) throws {
        guard response.paired else { throw DexcomG6Error.notPaired }
        isPaired = true
    }
    
    func createBackFillRequest(startTime: Int, endTime: Int) {
        guard isPaired else { return }
        LogController.log(
            message: "[Dexcom G6] Creating BackFill Request With StartTime %d EndTime %d",
            type: .debug,
            startTime,
            endTime
        )
        backFillStream = DexcomG6BackfillStream()
        let message = DexcomG6BackfillTxMessage(startTime: startTime, endTime: endTime)
        messageQueue.append(message)
        trySendingMessageFromQueue()
    }
    
    func createCalibrationRequest() {
        guard isPaired else { return }
        guard !isCalibrationMessageAlreadyQueued else {
            LogController.log(
                message: "[Dexcom G6] DexcomG6CalibrationTxMessage has been already queued",
                type: .debug
            )
            return
        }
        guard let calibration = Calibration.allForCurrentSensor.first,
              let date = calibration.date,
              !calibration.isSentToTransmitter else {
            LogController.log(
                message: "[Dexcom G6] Cannot find last valid calibration",
                type: .debug
            )
            return
        }
        
        let glucose = Int(calibration.glucoseLevel)
        
        let since = Date().timeIntervalSince1970 - date.timeIntervalSince1970
        
        if since < 0 {
            LogController.log(
                message: "[Dexcom G6] Cannot send calibration in future to transmitter %@",
                type: .debug,
                date.debugDescription
            )
            return
        }
        if since > TimeInterval.hours(1) {
            LogController.log(
                message: "[Dexcom G6] Cannot send calibration older than 1 hour to transmitter %@",
                type: .debug,
                date.debugDescription
            )
            return
        }
        if glucose < 40 || glucose > 400 {
            LogController.log(
                message: "[Dexcom G6] Calibration glucose value out of range %d",
                type: .debug,
                glucose
            )
            return
        }
        
        guard let transmitterStartDate = CGMDevice.current.transmitterStartDate else {
            LogController.log(
                message: "[Dexcom G6] Transmitter Start Date is nil",
                type: .debug
            )
            return
        }
        
        let timestamp = Int(date.timeIntervalSince1970 - transmitterStartDate.timeIntervalSince1970)
        
        let message = DexcomG6CalibrationTxMessage(glucose: glucose, time: timestamp)
        
        messageQueue.append(message)
        isCalibrationMessageAlreadyQueued = true
        trySendingMessageFromQueue()
        
        LogController.log(
            message: "[Dexcom G6] Queuing Calibration for transmitter: glucose %d, timestamp: %d",
            type: .debug,
            glucose,
            timestamp
        )
    }
    
    func createStopSensorRequest() {
        guard isPaired else { return }
        guard CGMDevice.current.sensorStopScheduleDate != nil else {
            LogController.log(
                message: "[Dexcom G6] DexcomG6SessionStopTxMessage Queuing Error: Stop is not scheduled",
                type: .debug
            )
            return
        }
        
        guard !isStopSensorMessageAlreadyQueued else {
            LogController.log(
                message: "[Dexcom G6] DexcomG6SessionStopTxMessage Queuing Error: Already queued",
                type: .debug
            )
            return
        }
        
        guard let transmitterStartDate = CGMDevice.current.transmitterStartDate else {
            LogController.log(
                message: "[Dexcom G6] DexcomG6SessionStopTxMessage Queuing Error: Transmitter Start Date is nil",
                type: .debug
            )
            return
        }
        
        let stopTime = Int(Date().timeIntervalSince1970 - transmitterStartDate.timeIntervalSince1970)
        let message = DexcomG6SessionStopTxMessage(stopTime: stopTime)
        messageQueue.append(message)
        isStopSensorMessageAlreadyQueued = true
        trySendingMessageFromQueue()
        
        LogController.log(
            message: "[Dexcom G6] DexcomG6SessionStopTxMessage Success: Queued",
            type: .debug
        )
    }
    
    func handleBackfillStream(_ data: Data?) {
        guard let data = data else { return }
        backFillStream.push(data)
        delegate?.workerDidReceiveBackfillData(backFillStream.decode())
    }

    private func trySendingMessageFromQueue() {
        guard !isQueueAwaitingForResponse else { return }
        guard !messageQueue.isEmpty else { return }
        
        isQueueAwaitingForResponse = true
        let message = messageQueue.removeFirst()
        delegate?.workerRequiresSendingOutgoingMessage(message)
    }
    
    func handleCalibrationRxMessage(_ message: DexcomG6CalibrationRxMessage) {
        if let calibration = Calibration.allForCurrentSensor.first {
            if !calibration.isSentToTransmitter {
                calibration.markCalibrationAsSentToTransmitter()
                LogController.log(
                message: "[Dexcom G6] Marked last calibration as sent to transmitter",
                type: .debug
            )}
        
            if let type = message.type {
                calibration.updateResponseType(type: type)
                calibration.updateResponseDate(date: Date())
            }
        }
        LogController.log(
            message: "[Dexcom G6] DexcomG6CalibrationRxMessage accepted : %@, calibrationResponseType : %@",
            type: .debug,
            message.accepted.description,
            message.type.debugDescription
        )
    }
    
    func handleSensorStopRxMessage(_ message: DexcomG6SessionStopRxMessage) {
        CGMDevice.current.updateSensorStopScheduleDate(nil)
        
        if !message.isOkay {
            CGMDevice.current.backupStartDate()
            CGMDevice.current.updateSensorIsStarted(true)
            CGMController.shared.notifyMetadataChanged(.sensorAge)
        }
    }
}

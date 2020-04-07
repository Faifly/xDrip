//
//  DexcomG6MessageWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class DexcomG6MessageWorker {
    private weak var delegate: DexcomG6MessageWorkerDelegate?
    
    private var isQueueAwaitingForResponse = false
    private var messageQueue: [DexcomG6OutgoingMessage] = []
    private let messageFactory = DexcomG6MessageFactory()
    private var isPaired = false {
        didSet {
            if isPaired {
                delegate?.workerDidSuccessfullyAuthorize()
            }
        }
    }
    
    init(delegate: DexcomG6MessageWorkerDelegate) {
        self.delegate = delegate
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
            delegate?.workerDidReceiveReading(message)
            
        case .batteryStatusRx:
            let message = try DexcomG6BatteryStatusRxMessage(data: data)
            delegate?.workerDidReceiveBatteryInfo(message)
            
        case .transmitterVersionRx:
            let message = try DexcomG6TransmitterVersionRxMessage(data: data)
            delegate?.workerDidReceiveTransmitterInfo(message)
            
        case .transmitterTimeRx:
            let message = try DexcomG6TransmitterTimeRxMessage(data: data)
            delegate?.workerDidReceiveTransmitterTimeInfo(message)
            
        default: break
        }
        
        isQueueAwaitingForResponse = false
        trySendingMessageFromQueue()
    }
    
    func createDataRequest(ofType type: DexcomG6OpCode) {
        guard isPaired || !type.requiresPairing else { return }
        guard let message = messageFactory.createOutgoingMessage(ofType: type) else { return }
        messageQueue.append(message)
        trySendingMessageFromQueue()
    }
    
    func requestRequiredData() {
        createDataRequest(ofType: .sensorDataTx)
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
    }
    
    private func sendChallengeRequest(authResponse: DexcomG6AuthRequestRxMessage) throws {
        isPaired = false
        guard let serial = CGMDevice.current.metadata(ofType: .serialNumber)?.value else { return }
        let message = try DexcomG6AuthChallengeTxMessage(challenge: authResponse.challenge, serial: serial)
        delegate?.workerRequiresSendingOutgoingMessage(message)
    }
    
    private func handleAuthResponse(_ response: DexcomG6AuthChallengeRxMessage) throws {
        guard response.authenticated else { throw DexcomG6Error.notAuthenticated }
        isPaired = true
    }
    
    private func handlePairResponse(_ response: DexcomG6PairRequestRxMessage) throws {
        guard response.paired else { throw DexcomG6Error.notPaired }
        isPaired = true
    }
    
    private func trySendingMessageFromQueue() {
        guard !isQueueAwaitingForResponse else { return }
        guard messageQueue.count > 0 else { return }
        
        isQueueAwaitingForResponse = true
        let message = messageQueue.removeFirst()
        delegate?.workerRequiresSendingOutgoingMessage(message)
    }
}

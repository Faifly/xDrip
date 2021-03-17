//
//  HomeSensorStateWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 03.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol HomeSensorStateWorkerLogic {
    func subscribeForSensorStateChange(callback: @escaping (Home.SensorState) -> Void)
}

final class HomeSensorStateWorker: HomeSensorStateWorkerLogic {
    private var callback: ((Home.SensorState) -> Void)?
    private var isWarmingUp = false
    private var timer: Timer?
    private var settingsObservers: [NSObjectProtocol] = []
    private var calibrationObserver: NSObjectProtocol?
    
    func subscribeForSensorStateChange(callback: @escaping (Home.SensorState) -> Void) {
        self.callback = callback
        checkWarmUpState()
        CGMController.shared.subscribeForMetadataEvents(listener: self) { [weak self] type in
            if type == .sensorAge {
                self?.checkWarmUpState()
            }
        }
        
        CGMController.shared.subscribeForGlucoseDataEvents(listener: self) { [weak self] _ in
            guard let self = self else { return }
            self.checkWarmUpState()
        }
        
        settingsObservers = NotificationCenter.default.subscribe(
            forSettingsChange: [.warmUp, .sensorStarted]
        ) { [weak self] in
            self?.checkWarmUpState()
        }
        
        calibrationObserver = NotificationCenter.default.addObserver(
            forName: .regularCalibrationCreated,
            object: nil,
            queue: nil,
            using: { [weak self] _ in
                self?.checkWarmUpState()
            }
        )
    }
    
    deinit {
        CGMController.shared.unsubscribeFromMetadataEvents(listener: self)
        CGMController.shared.unsubscribeFromGlucoseDataEvents(listener: self)
        settingsObservers.forEach { NotificationCenter.default.removeObserver($0) }
        if let observer = calibrationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func startCheckTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { [weak self] _ in
                self?.checkWarmUpState()
            })
        }
    }
    
    private func stopCheckTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkWarmUpState() {
        if CGMDevice.current.isWarmingUp {
            isWarmingUp = true
            guard let stringAge = CGMDevice.current.metadata(ofType: .sensorAge)?.value else { return }
            guard let intervalAge = TimeInterval(stringAge) else { return }
            guard let type = CGMDevice.current.deviceType else { return }
            let age = Date().timeIntervalSince1970 - intervalAge
            let minutesLeft = Int((type.warmUpInterval - age) / 60.0)
            callback?(.warmingUp(minutesLeft: minutesLeft))
            
            startCheckTimer()
        } else if isWarmingUp {
            isWarmingUp = false
            let state: Home.SensorState
            
            let errorMessage = createErrorMessage()
            
            if CGMDevice.current.sensorStartDate != nil {
                state = Calibration.allForCurrentSensor.count > 1 ?
                    .started(errorMessage: errorMessage) :
                    .waitingReadings
            } else {
                state = .stopped
            }
            
            if errorMessage != nil {
                startCheckTimer()
            } else {
                stopCheckTimer()
            }
            
            callback?(state)
        } else {
            isWarmingUp = false
            let state: Home.SensorState
            
            let errorMessage = createErrorMessage()
            
            if CGMDevice.current.sensorStartDate != nil {
                state = Calibration.allForCurrentSensor.count > 1 ?
                    .started(errorMessage: errorMessage) :
                    .waitingReadings
            } else {
                state = .stopped
            }
            
            if errorMessage != nil {
                startCheckTimer()
            } else {
                stopCheckTimer()
            }
            
            callback?(state)
        }
    }
    
    func createErrorMessage() -> String? {
        if let calibration = Calibration.allForCurrentSensor.first,
           let responseType = calibration.responseType ,
           let rawType = UInt8(responseType) ,
           let type = DexcomG6CalibrationResponseType(rawValue: rawType),
           !(type == .okay || type == .secondCalibrationNeeded || type == .duplicate) {
            guard let calibrationInterval = calibration.creationDate?.timeIntervalSince1970 else {
                return "Create new calibration"
            }
            let interval = Date().timeIntervalSince1970
            let calibrationAge = interval - calibrationInterval
            let waitDuration = TimeInterval(minutes: 2)
            let diff = (waitDuration - calibrationAge) / 60.0
            let intDiff = Int(diff)
            
            return intDiff > 0 ? "Create new calibration in \(intDiff) minutes" : "Create new calibration now"
        }
        
        if let calibrationStateValue = GlucoseReading.allMaster.first?.calibrationState,
           let rawState = UInt8(calibrationStateValue),
           let state = DexcomG6CalibrationState(rawValue: rawState) {
            switch state {
            case .okay: break
            case .warmingUp: return "Sensor is warming up"
            default:
                return "Reading calibration state error"
            }
        }
        return nil
    }
}

extension HomeSensorStateWorker: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(1)
    }
    
    static func == (lhs: HomeSensorStateWorker, rhs: HomeSensorStateWorker) -> Bool {
        return true
    }
}

private extension Home.WarmUpState {
    static var notWarming: Home.WarmUpState {
        return Home.WarmUpState(isWarmingUp: false, minutesLeft: nil)
    }
}

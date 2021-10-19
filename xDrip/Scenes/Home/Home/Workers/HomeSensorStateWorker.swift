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

enum CalibrationStateError {
    case sensorIsWarmingUp
    case needNewCalibration
    case needAdditionalCalibration
    case needNewCalibrationIn(minutes: Int)
    case needNewCalibrationAgain
    case waitingReadings
    case startingSensor
}

final class HomeSensorStateWorker: HomeSensorStateWorkerLogic {
    private var callback: ((Home.SensorState) -> Void)?
    private var isWarmingUp = false
    private var timer: Timer?
    private var settingsObservers: [NSObjectProtocol] = []
    private var calibrationObserver: NSObjectProtocol?
    
    func subscribeForSensorStateChange(callback: @escaping (Home.SensorState) -> Void) {
        self.callback = callback
        checkSensorState()
        CGMController.shared.subscribeForMetadataEvents(listener: self) { [weak self] type in
            if type == .sensorAge {
                self?.checkSensorState()
            }
        }
        
        CGMController.shared.subscribeForGlucoseDataEvents(listener: self) { [weak self] _ in
            guard let self = self else { return }
            self.checkSensorState()
        }
        
        settingsObservers = NotificationCenter.default.subscribe(
            forSettingsChange: [.warmUp, .sensorStarted, .deviceMode]
        ) { [weak self] in
            self?.checkSensorState()
        }
        
        calibrationObserver = NotificationCenter.default.addObserver(
            forName: .regularCalibrationCreated,
            object: nil,
            queue: nil,
            using: { [weak self] _ in
                self?.checkSensorState()
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
                self?.checkSensorState()
            })
        }
    }
    
    private func stopCheckTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkSensorState() {
        if (User.current.settings.deviceMode == .follower) {
            callback?(.notDefined)
        } else {
            if CGMDevice.current.isWarmingUp {
                isWarmingUp = true
                guard let stringAge = CGMDevice.current.metadata(ofType: .sensorAge)?.value else { return }
                guard let intervalAge = TimeInterval(stringAge) else { return }
                guard let type = CGMDevice.current.deviceType else { return }
                let age = Date().timeIntervalSince1970 - intervalAge
                let minutesLeft = Int((type.warmUpInterval - age) / 60.0)
                callback?(.warmingUp(minutesLeft: minutesLeft))
                
                startCheckTimer()
            } else {
                isWarmingUp = false
                let state: Home.SensorState
                
                let errorMessage = createErrorMessage()
                var waitForStop = false
                
                if CGMDevice.current.sensorStartDate != nil {
                    state = .started(errorMessage: errorMessage)
                } else {
                    waitForStop = CGMDevice.current.sensorStopScheduleDate != nil
                    state = .stopped(waitForStop: waitForStop)
                }
                
                if errorMessage != nil || waitForStop {
                    startCheckTimer()
                } else {
                    stopCheckTimer()
                }
                
                callback?(state)
            }
        }
    }
    
    func createErrorMessage() -> CalibrationStateError? {
        if CGMDevice.current.withCalibrationResponse {
            let lastReading = GlucoseReading.allMaster(valid: false).first
            let lastReadingCalibrationState = lastReading?.calibrationState
            
            let lastCalibration = Calibration.allForCurrentSensor.first
            let lastCalibrationResponseType = lastCalibration?.responseType
            
            if let state = lastReadingCalibrationState, state == .warmingUp {
                return .sensorIsWarmingUp
            }
            
            if let calibration = lastCalibration, let type = lastCalibrationResponseType,
               !DexcomG6CalibrationResponseType.validCollection.contains(type) {
                guard let calibrationInterval = calibration.responseDate?.timeIntervalSince1970 else {
                    return .needNewCalibration
                }
                let interval = Date().timeIntervalSince1970
                let calibrationAge = interval - calibrationInterval
                let waitDuration = TimeInterval(minutes: 6)
                let diff = (waitDuration - calibrationAge) / 60.0
                let intDiff = Int(diff)
                
                return intDiff > 0 ? .needNewCalibrationIn(minutes: intDiff) : .needNewCalibration
            }
            
            if let state = lastReadingCalibrationState {
                switch state {
                case .okay, .needsCalibration: return nil
                case _ where DexcomG6CalibrationState.stoppedCollection.contains(state): return .startingSensor
                case .needsFirstCalibration:
                    if let calibration = lastCalibration, !calibration.isSentToTransmitter {
                        return .waitingReadings
                    } else {
                        return .needNewCalibration
                    }
                case .needsSecondCalibration:
                    if let calibration = lastCalibration, !calibration.isSentToTransmitter {
                        return .waitingReadings
                    } else {
                        return .needAdditionalCalibration
                    }
                default:
                    if let calibration = lastCalibration, !calibration.isSentToTransmitter {
                        return nil
                    } else {
                        return .needNewCalibration
                    }
                }
            }
            return nil
        } else {
            if Calibration.allForCurrentSensor.count > 1 {
                return nil
            } else {
                return .waitingReadings
            }
        }
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

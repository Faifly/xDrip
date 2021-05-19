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
    case needNewCalibrationNow
    case needNewCalibrationIn(minutes: Int)
    case needNewCalibrationAgain
    case waitingReadings
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
                state = .started(errorMessage: errorMessage)
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
                state = .started(errorMessage: errorMessage)
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
    
    func createErrorMessage() -> CalibrationStateError? {
        if let firstVersionCharacter = CGMDevice.current.transmitterVersionString?.first,
           let transmitterVersion = DexcomG6FirmwareVersion(rawValue: firstVersionCharacter),
           transmitterVersion == .second {
            let lastReading = GlucoseReading.allMaster.first
            let lastReadingCalibrationState = lastReading?.сalibrationState
            
            let lastCalibration = Calibration.allForCurrentSensor.first
            let lastCalibrationResponseType = lastCalibration?.responseType
            
            if let state = lastReadingCalibrationState, state == .warmingUp {
                return .sensorIsWarmingUp
            }
            
            if lastCalibration == nil, lastReading != nil {
                return .needNewCalibrationNow
            }
            
            if let calibration = lastCalibration, let type = lastCalibrationResponseType,
               !(type == .okay || type == .secondCalibrationNeeded || type == .duplicate) {
                guard let calibrationInterval = calibration.responseDate?.timeIntervalSince1970 else {
                    return .needNewCalibrationNow
                }
                let interval = Date().timeIntervalSince1970
                let calibrationAge = interval - calibrationInterval
                let waitDuration = TimeInterval(minutes: 6)
                let diff = (waitDuration - calibrationAge) / 60.0
                let intDiff = Int(diff)
                
                return intDiff > 0 ? .needNewCalibrationIn(minutes: intDiff) : .needNewCalibrationNow
            }
            
            if let state = lastReadingCalibrationState {
                switch state {
                case .okay: return nil
                default:
                    if let calibration = lastCalibration, !calibration.isSentToTransmitter {
                        return nil
                    } else {
                        return .needNewCalibrationNow
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

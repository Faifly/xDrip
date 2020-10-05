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
    
    func subscribeForSensorStateChange(callback: @escaping (Home.SensorState) -> Void) {
        self.callback = callback
        checkWarmUpState()
        CGMController.shared.subscribeForMetadataEvents(listener: self) { [weak self] type in
            if type == .sensorAge {
                self?.checkWarmUpState()
            }
        }
        settingsObservers = NotificationCenter.default.subscribe(
            forSettingsChange: [.warmUp, .sensorStarted]
        ) { [weak self] in
            self?.checkWarmUpState()
        }
    }
    
    deinit {
        CGMController.shared.unsubscribeFromMetadataEvents(listener: self)
        settingsObservers.forEach { NotificationCenter.default.removeObserver($0) }
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
            
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { [weak self] _ in
                    self?.checkWarmUpState()
                })
            }
        } else if isWarmingUp {
            isWarmingUp = false
            timer?.invalidate()
            timer = nil
            let state: Home.SensorState
            
            if CGMDevice.current.sensorStartDate != nil {
                state = Calibration.allForCurrentSensor.count > 1 ? .started : .waitingReadings
            } else {
                state = .stopped
            }
            
            callback?(state)
        } else {
            isWarmingUp = false
            timer?.invalidate()
            timer = nil
            let state: Home.SensorState
            
            if CGMDevice.current.sensorStartDate != nil {
                state = Calibration.allForCurrentSensor.count > 1 ? .started : .waitingReadings
            } else {
                state = .stopped
            }
            
            callback?(state)
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

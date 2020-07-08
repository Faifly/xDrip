//
//  HomeWarmUpWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 03.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol HomeWarmUpWorkerLogic {
    func subscribeForWarmUpStateChange(callback: @escaping (Home.WarmUpState) -> Void)
}

final class HomeWarmUpWorker: HomeWarmUpWorkerLogic {
    private var callback: ((Home.WarmUpState) -> Void)?
    private var isWarmingUp = false
    private var timer: Timer?
    private var settingsObservers: [NSObjectProtocol] = []
    
    func subscribeForWarmUpStateChange(callback: @escaping (Home.WarmUpState) -> Void) {
        self.callback = callback
        checkWarmUpState()
        CGMController.shared.subscribeForMetadataEvents(listener: self) { [weak self] type in
            if type == .sensorAge {
                self?.checkWarmUpState()
            }
        }
        settingsObservers = NotificationCenter.default.subscribe(forSettingsChange: [.warmUp]) { [weak self] in
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
            let state = Home.WarmUpState(
                isWarmingUp: true,
                minutesLeft: Int((type.warmUpInterval - age) / 60.0)
            )
            callback?(state)
            
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { [weak self] _ in
                    self?.checkWarmUpState()
                })
            }
        } else if isWarmingUp {
            isWarmingUp = false
            timer?.invalidate()
            timer = nil
            callback?(.notWarming)
        }
    }
}

extension HomeWarmUpWorker: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(1)
    }
    
    static func == (lhs: HomeWarmUpWorker, rhs: HomeWarmUpWorker) -> Bool {
        return true
    }
}

private extension Home.WarmUpState {
    static var notWarming: Home.WarmUpState {
        return Home.WarmUpState(isWarmingUp: false, minutesLeft: nil)
    }
}

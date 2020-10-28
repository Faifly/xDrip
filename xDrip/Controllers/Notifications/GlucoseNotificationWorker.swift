//
//  GlucoseNotificationWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 22.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AKUtils

final class GlucoseNotificationWorker: NSObject {
    typealias RepeatAlertData = (isEnabled: Bool, lastFireTimestamp: TimeInterval, repeatCount: Int)
    
    var notificationRequest: ((AlertEventType) -> Void)?
    
    private lazy var settingsChangeObserver: [NSObjectProtocol] = NotificationCenter.default.subscribe(
        forSettingsChange: [.alertRepeat, .fastRise, .fastDrop, .urgentHigh, .urgentLow, .high, .low, .sensorStarted]
    ) { [weak self] setting in
        guard let self = self else { return }
        
        var alertType: AlertEventType?
        switch setting {
        case .fastRise: alertType = .fastRise
        case .fastDrop: alertType = .fastDrop
        case .urgentLow: alertType = .urgentLow
        case .urgentHigh: alertType = .urgentHigh
        case .high: alertType = .high
        case .low: alertType = .low
        case .alertRepeat: self.disableAlertsRelatedToDefaultConfig(); return
        case .sensorStarted:
            self.resetMissedReadingsTimer()
        default: break
        }
        
        if let type = alertType {
            self.disableAlert(type)
        }
    }
    
    private var alertTimer: RepeatingTimer?
    private var missedReadingsTimer: RepeatingTimer?
    private var repeatAlertsData = [AlertEventType: RepeatAlertData]()
    
    override init() {
        super.init()
        CGMController.shared.subscribeForGlucoseDataEvents(listener: self) { [weak self] reading in
            guard let reading = reading, let self = self else { return }
            if User.current.settings.deviceMode == .main {
                guard Calibration.allForCurrentSensor.count > 1 else { return }
            }
            
            self.checkFastRise()
            self.checkFastDrop()
            self.checkWarningLevel(for: reading)
            self.resetMissedReadingsTimer()
        }
        
        _ = settingsChangeObserver
        
        resetMissedReadingsTimer()
        resetAlertTimer()
        setupRepeatAlertsData()
    }
    
    deinit {
        CGMController.shared.unsubscribeFromGlucoseDataEvents(listener: self)
    }
    
    private func resetMissedReadingsTimer() {
        let readings = GlucoseReading.lastReadings(4, for: User.current.settings.deviceMode)
        guard CGMDevice.current.isSensorStarted, !readings.isEmpty else {
            missedReadingsTimer = nil
            return
        }
        
        var timeInterval = Constants.Glucose.defaultMissedReadingTimeInterval
        if readings.count == Constants.Glucose.requiredReadingsCountToCalculateInterval {
            var interval = 0.0
            var count = 0.0
            
            for index in 1 ..< readings.count {
                if let date1 = readings[index - 1].date, let date2 = readings[index].date {
                    interval += date1.timeIntervalSince(date2)
                    count += 1.0
                }
            }
            
            if count >= 2 {
                timeInterval = 2.0 * interval / count
            }
        }
        
        missedReadingsTimer = nil
        missedReadingsTimer = RepeatingTimer(timeInterval: timeInterval)
        missedReadingsTimer?.eventHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.checkMissedReadings()
            }
        }
        missedReadingsTimer?.resume()
    }
    
    private func resetAlertTimer() {
        alertTimer = nil
        alertTimer = RepeatingTimer(timeInterval: 60.0)
        alertTimer?.eventHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.repeatAlerts()
            }
        }
        alertTimer?.resume()
    }
    
    private func repeatAlerts() {
        let alertsData = repeatAlertsData.filter({ $0.value.isEnabled })
        
        for data in alertsData {
            let now = Date().timeIntervalSince1970
            if AlertEventType.warningLevelAlerts.contains(data.key) {
                let config = User.current.settings.alert.customConfiguration(for: data.key)
                if config.isOverriden {
                    guard config.repeat else { continue }
                } else if let defaultConfig = User.current.settings.alert.defaultConfiguration {
                    guard defaultConfig.repeat else { continue }
                }
                
                if now - data.value.lastFireTimestamp > 60.0 {
                    fireAlert(ofType: data.key)
                
                    if repeatAlertsData[data.key]?.repeatCount >? Constants.Notifications.maximumRepeatCount {
                        disableAlert(data.key)
                    }
                }
            } else if data.key == .phoneMuted {
                if now - data.value.lastFireTimestamp > Constants.Glucose.defaultPhoneMutedCheckTimeInterval {
                    checkMuted()
                }
            }
        }
    }
    
    private func fireAlert(ofType type: AlertEventType) {
        notificationRequest?(type)
        enableAlert(type)
        repeatAlertsData[type]?.1 = Date().timeIntervalSince1970
        resetAlertTimer()
    }
    
    private func setupRepeatAlertsData() {
        let alertTypes = AlertEventType.warningLevelAlerts
        
        for type in alertTypes {
            if let config = User.current.settings.alert?.customConfiguration(for: type), config.isOverriden {
                if config.repeat {
                    disableAlert(type)
                }
            } else if let defaultConfig = User.current.settings.alert?.defaultConfiguration {
                if defaultConfig.repeat {
                    disableAlert(type)
                }
            }
        }
        
        enableAlert(.phoneMuted)
    }
    
    private func disableAlertsRelatedToDefaultConfig() {
        let alertTypes = AlertEventType.warningLevelAlerts
        
        for type in alertTypes {
            if let config = User.current.settings.alert?.customConfiguration(for: type),
                !config.isOverriden,
                let defaultConfig = User.current.settings.alert?.defaultConfiguration {
                if defaultConfig.repeat {
                    disableAlert(type)
                }
            }
        }
    }
    
    private func enableAlert(_ type: AlertEventType) {
        repeatAlertsData[type] = (true, repeatAlertsData[type]?.1 ?? 0.0, (repeatAlertsData[type]?.2 ?? 0) + 1)
    }
    
    private func disableAlert(_ type: AlertEventType) {
        repeatAlertsData[type] = (false, 0.0, 0)
    }
    
    private func checkMuted() {
        MuteChecker.shared.checkMute { [weak self] isMuted in
            if isMuted {
                self?.fireAlert(ofType: .phoneMuted)
            } else {
                NotificationCenter.default.post(name: .notMuted, object: nil)
            }
        }
    }
    
    private func checkMissedReadings() {
        notificationRequest?(.missedReadings)
    }
    
    private func checkFastRise() {
        if isGlucoseChangingFast(isRise: true) {
            fireAlert(ofType: .fastRise)
        } else {
            disableAlert(.fastRise)
        }
    }
    
    private func checkFastDrop() {
        if isGlucoseChangingFast(isRise: false) {
            notificationRequest?(.fastDrop)
        } else {
            disableAlert(.fastDrop)
        }
    }
    
    private func checkWarningLevel(for reading: GlucoseReading) {
        disableAlert(.urgentLow)
        disableAlert(.low)
        disableAlert(.high)
        disableAlert(.urgentHigh)
        
        guard let warningLevel = User.current.settings.warningLevel(forValue: reading.calculatedValue) else {
            return
        }
        
        switch warningLevel {
        case .urgentLow:
            fireAlert(ofType: .urgentLow)
            
        case .low:
            fireAlert(ofType: .low)
            
        case .high:
            fireAlert(ofType: .high)
            
        case .urgentHigh:
            fireAlert(ofType: .urgentHigh)
        }
    }
    
    private func isGlucoseChangingFast(isRise: Bool) -> Bool {
        let last3 = GlucoseReading.latestByCount(3, for: User.current.settings.deviceMode)
        
        guard last3.count == 3 else {
            return false
        }
        
        let lastReading = last3[0]
        let middleReading = last3[1]
        let firstReading = last3[2]
        
        var highThreshold = User.current.settings.warningLevelValue(for: .high)
        var lowThreshold = User.current.settings.warningLevelValue(for: .low)
        var minimumBGChange = 10.0
        
        if let config = User.current.settings.alert?.customConfiguration(for: isRise ? .fastRise : .fastDrop) {
            highThreshold = Double(config.highThreshold)
            lowThreshold = Double(config.lowThreshold)
            minimumBGChange = Double(config.minimumBGChange)
        }
        
        guard
            lastReading.calculatedValue !~ 0.0,
            middleReading.calculatedValue !~ 0.0,
            firstReading.calculatedValue !~ 0.0,
            lastReading.calculatedValue <= highThreshold,
            lastReading.calculatedValue >= lowThreshold
        else { return false }
        
        let date = Date()
        let nineMinutes = TimeInterval.secondsPerMinute * 9.0
        guard
            let lastDate = lastReading.date,
            let middleDate = middleReading.date,
            let firstDate = firstReading.date,
            date.timeIntervalSince(lastDate) < nineMinutes,
            lastDate.timeIntervalSince(middleDate) < nineMinutes,
            middleDate.timeIntervalSince(firstDate) < nineMinutes
        else { return false }
        
        let lastSlope = lastReading.calculatedValue - middleReading.calculatedValue
        let middleSlope = middleReading.calculatedValue - firstReading.calculatedValue
        
        var isChangingFast = false
        if isRise {
            if middleSlope >= minimumBGChange, lastSlope >= minimumBGChange {
                isChangingFast = true
            }
        } else {
            if middleSlope <= -1 * minimumBGChange, lastSlope <= -1 * minimumBGChange {
                isChangingFast = true
            }
        }
        
        return isChangingFast
    }
}

extension Notification.Name {
    static let notMuted = Notification.Name("NotMuted")
}

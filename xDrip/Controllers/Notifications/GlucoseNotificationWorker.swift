//
//  GlucoseNotificationWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 22.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class GlucoseNotificationWorker: NSObject {
    var notificationRequest: ((AlertEventType) -> Void)?
    
    override init() {
        super.init()
        CGMController.shared.subscribeForGlucoseDataEvents(listener: self) { [weak self] reading in
            guard let reading = reading, let self = self else { return }
            self.checkFastRise()
            self.checkFastDrop()
            self.checkWarningLevel(for: reading)
        }
    }
    
    private func checkFastRise() {
        if isGlucoseChangingFast(isRise: true) {
            notificationRequest?(.fastRise)
        }
    }
    
    private func checkFastDrop() {
        if isGlucoseChangingFast(isRise: false) {
            notificationRequest?(.fastDrop)
        }
    }
    
    private func checkWarningLevel(for reading: GlucoseReading) {
        guard let warningLevel = User.current.settings.warningLevel(forValue: reading.calculatedValue) else {
            return
        }
        
        switch warningLevel {
        case .urgentLow: notificationRequest?(.urgentLow)
        case .low: notificationRequest?(.low)
        case .high: notificationRequest?(.high)
        case .urgentHigh: notificationRequest?(.urgentHigh)
        }
    }
    
    private func isGlucoseChangingFast(isRise: Bool) -> Bool {
        let readings = User.current.settings.deviceMode == .main ? GlucoseReading.lastMasterReadings(3) : []
        
        guard readings.count == 3 else {
            return false
        }
        
        let lastReading = readings[0]
        let middleReading = readings[1]
        let firstReading = readings[2]
        
        var highThreshold = User.current.settings.warningLevelValue(for: .high)
        var lowThreshold = User.current.settings.warningLevelValue(for: .low)
        var minimumBGChange = 10.0
        
        if let config = User.current.settings.alert?.getCustomConfiguration(for: isRise ? .fastRise : .fastDrop) {
            highThreshold = Double(config.highThreshold)
            lowThreshold = Double(config.lowThreshold)
            minimumBGChange = Double(config.minimumBGChange)
        }
        
        guard
            lastReading.calculatedValue != 0.0,
            middleReading.calculatedValue != 0,
            firstReading.calculatedValue != 0,
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

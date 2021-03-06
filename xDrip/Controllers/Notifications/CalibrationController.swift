//
//  CalibrationController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class CalibrationController {
    static let shared = CalibrationController()
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    private var initialCalibrationRequested = false
    private var regularCalibrationRequested = false
    
    func requestInitialCalibration() {
        NotificationController.shared.sendNotification(ofType: .initialCalibrationRequest,
                                                       shouldShow: UIApplication.shared.applicationState != .active)
        
        guard !initialCalibrationRequested else { return }
        initialCalibrationRequested = true
        
        if UIApplication.shared.applicationState == .active {
            showActiveAppInitialCalibrationAlert()
        }
    }
    
    func requestRegularCalibration() {
        if UIApplication.shared.applicationState != .active {
            NotificationController.shared.sendNotification(ofType: .calibrationRequest)
        }
        guard !NotificationController.shared.isNotificationSnoozed(ofType: .calibrationRequest) else { return }        
        guard !initialCalibrationRequested && !regularCalibrationRequested else { return }
        regularCalibrationRequested = true
        
        if UIApplication.shared.applicationState == .active {
            showActiveAppRegularCalibrationAlert()
        }
    }
    
    func initialCalibrationCompleted() {
        initialCalibrationRequested = false
    }
    
    func regularCalibrationCompleted() {
        regularCalibrationRequested = false
    }
    
    private func showActiveAppInitialCalibrationAlert() {
        let alert = UIAlertController(
            title: "calibration_initial_alert_title".localized,
            message: "calibration_initial_alert_message".localized,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(
            title: "calibration_initial_alert_cancel_button".localized,
            style: .cancel) { _ in
                self.initialCalibrationCompleted()
        }
        
        alert.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(
            title: "calibration_initial_alert_proceed_button".localized,
            style: .default
        ) { _ in
            let calibrationController = EditCalibrationViewController()
            calibrationController.dismissHandler = {
                self.initialCalibrationCompleted()
            }
            let navigationController = UINavigationController(rootViewController: calibrationController)
            UIApplication.topViewController()?.present(navigationController, animated: true)
        }
        alert.addAction(confirmAction)
        
        AlertPresenter.shared.presentAlert(alert)
    }
    
    private func showActiveAppRegularCalibrationAlert() {
        let alert = UIAlertController(
            title: "calibration_regular_alert_title".localized,
            message: "calibration_regular_alert_message".localized,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(
            title: "calibration_regular_alert_cancel_button".localized,
            style: .cancel
        ) { _ in
            NotificationController.shared.scheduleSnoozeForNotification(ofType: .calibrationRequest)
            self.regularCalibrationCompleted()
        }
        alert.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(
            title: "calibration_regular_alert_proceed_button".localized,
            style: .default
        ) { _ in
            let calibrationController = EditCalibrationViewController()
            calibrationController.dismissHandler = {
                self.regularCalibrationCompleted()
            }
            let navigationController = UINavigationController(rootViewController: calibrationController)
            UIApplication.topViewController()?.present(navigationController, animated: true)
        }
        alert.addAction(confirmAction)
        
        AlertPresenter.shared.presentAlert(alert)
    }
    
    @objc private func applicationDidBecomeActive() {
        if initialCalibrationRequested {
            showActiveAppInitialCalibrationAlert()
        }
        
        if regularCalibrationRequested {
            showActiveAppRegularCalibrationAlert()
        }
    }
    
    func isOptimalConditionToCalibrate() -> Bool {
        let masterReadings = GlucoseReading.allMasterForCurrentSensor()
        
        guard masterReadings.count >= 3 else { return false }
        //We have at least 3 readings
        let lastReading = masterReadings[0]
        let middleReading = masterReadings[1]
        let firstReading = masterReadings[2]
        
        guard lastReading.calculatedValue !~ 0 && middleReading.calculatedValue !~ 0 &&
            firstReading.calculatedValue !~ 0 else { return false }
        //Last 3 readings are valid
        
        guard let lastReadingDate = lastReading.date, let middleReadingDate = middleReading.date,
            let firstReadingDate = firstReading.date else { return false }
        
        let presentTimeInterval = Date().timeIntervalSince1970
        let lastReadingTimeInterval = lastReadingDate.timeIntervalSince1970
        let middleReadingTimeInterval = middleReadingDate.timeIntervalSince1970
        let firstReadingTimeInterval = firstReadingDate.timeIntervalSince1970
        let sixMinutesInterval = 360.0
        
        guard presentTimeInterval - lastReadingTimeInterval < sixMinutesInterval &&
            lastReadingTimeInterval - middleReadingTimeInterval < sixMinutesInterval &&
            middleReadingTimeInterval - firstReadingTimeInterval < sixMinutesInterval else { return false }
        
        //All readings are not more than 6 minutes apart
        let lastReadingSlope = abs(lastReading.calculatedValue - middleReading.calculatedValue)
        let middleReadingSlope = abs(middleReading.calculatedValue - firstReading.calculatedValue)
        
        guard lastReadingSlope <= 3 && middleReadingSlope <= 3 else { return false }
        
        //Not going up or down by more than 3mg/dL
        let highThreshold = User.current.settings.warningLevelValue(for: .high) * 1.25
        let lowThreshold = User.current.settings.warningLevelValue(for: .low)
        
        guard (lastReading.calculatedValue < highThreshold && lastReading.calculatedValue > lowThreshold) &&
            (middleReading.calculatedValue < highThreshold && middleReading.calculatedValue > lowThreshold) &&
            (firstReading.calculatedValue < highThreshold && firstReading.calculatedValue > lowThreshold) else {
                return false
        }
        //All readings are within "in-range" threshold.
        //Optimal calibration condition has been reached!
        
        return true
    }
    
    func canShowNextRegularCalibrationRequest() -> Bool {
        var canShow = false
        if let lastCalibrationDate = Calibration.allForCurrentSensor.first?.date {
            let presentTimeInterval = Date().timeIntervalSince1970
            let calibrationTimeInterval = lastCalibrationDate.timeIntervalSince1970
            let diffInHours = (presentTimeInterval - calibrationTimeInterval) / .secondsPerHour
            if diffInHours > 12 {
                canShow = true
            }
        }
        return canShow
    }
}

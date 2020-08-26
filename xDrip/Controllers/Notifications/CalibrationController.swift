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
        if UIApplication.shared.applicationState != .active {
            NotificationController.shared.sendNotification(ofType: .initialCalibrationRequest)
        }
        
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
}

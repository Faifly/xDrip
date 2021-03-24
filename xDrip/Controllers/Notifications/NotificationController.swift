//
//  NotificationController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import UserNotifications

final class NotificationController: NSObject {
    private let defaultCategoryID = "AlertEvent"
    private let snoozableNotificationCategoryID = "SnoozableNotification"
    
    static let shared = NotificationController()
    private var glucoseNotificationWorker = GlucoseNotificationWorker()
    
    private var alertSentCount = [AlertEventType: Int]()
    private var alertSkipCount = [AlertEventType: Int]()
    private var notificationObservers = [NSObjectProtocol?]()
    
    private var notAliveNotificationTimer: RepeatingTimer?
    
    override private init() {
        super.init()
        setupNotificationObservers()
        resetNotAliveNotification()
    }
    
    func resetNotAliveNotification() {
        removeAppStoppedNotificationFromQueue()
        addAppStoppedNotificationToQueue()
        notAliveNotificationTimer = RepeatingTimer(timeInterval: TimeInterval(minutes: 6))
        notAliveNotificationTimer?.eventHandler = { [weak self] in
            self?.removeAppStoppedNotificationFromQueue()
            self?.addAppStoppedNotificationToQueue()
        }
        notAliveNotificationTimer?.resume()
    }
    
    deinit {
        CGMController.shared.unsubscribeFromGlucoseDataEvents(listener: self)
        notificationObservers.removeAll()
    }
    
    func setupService() {
        getAuthStatus { [weak self] auth in
            switch auth {
            case .notDetermined:
                self?.requestAuthorization()
            case .denied:
                DispatchQueue.main.async {
                    self?.showDeniedAuthAlert()
                }
            default:
                break
            }
        }
    }
    
    private func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { [weak self] granted, error in
            if let error = error {
                LogController.log(message: "Error while request notification authorization", type: .error, error: error)
            }
            
            if granted {
                self?.setupCategories()
            }
        }
    }
    
    private func getAuthStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    private func showDeniedAuthAlert() {
        let alert = UIAlertController(
            title: "notification_error_title".localized,
            message: "notification_error_not_allowed".localized,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        
        let settingsAction = UIAlertAction(
            title: "notification_error_alert_settings_button_title".localized,
            style: .default
        ) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        alert.addAction(settingsAction)
        
        AlertPresenter.shared.presentAlert(alert)
    }
    
    private func setupCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "snooze_action",
            title: "notification_snooze".localized,
            options: .authenticationRequired
        )
        
        let alertEventCategory = UNNotificationCategory(
            identifier: snoozableNotificationCategoryID,
            actions: [snoozeAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([alertEventCategory])
    }
    
    private func setupNotificationObservers() {
        glucoseNotificationWorker.notificationRequest = { [weak self] alertType in
            guard let self = self else { return }
            self.sendNotification(ofType: alertType)
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        CGMController.shared.subscribeForGlucoseDataEvents(listener: self) { [weak self] _ in
            self?.alertSentCount[.missedReadings] = 0
            self?.alertSkipCount[.missedReadings] = 0
        }
        
        notificationObservers.append(createObserver(for: .calibrationRequest))
        notificationObservers.append(createObserver(for: .phoneMuted))
    }
    
    private func createObserver(for type: AlertEventType) -> NSObjectProtocol? {
        var notificationName: Notification.Name?
        switch type {
        case .calibrationRequest:
            notificationName = .regularCalibrationCreated
        case .phoneMuted:
            notificationName = .notMuted
        default:
            break
        }
        
        guard let name = notificationName else { return nil }
        
        return NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: nil,
            using: { [weak self] _ in
                self?.alertSentCount[type] = 0
                self?.alertSkipCount[type] = 0
            }
        )
    }
    
    private func setupPostponableAlerts() {
        for type in AlertEventType.postponableAlerts {
            alertSkipCount[type] = 0
            alertSentCount[type] = 0
        }
    }
    
    func sendNotification(ofType type: AlertEventType) {
        guard canSendNotification(ofType: type) else { return }
        guard let settings = User.current.settings.alert, settings.isNotificationsEnabled else { return }
        let config = settings.customConfiguration(for: type)
        guard config.isEnabled else { return }
        
        let date = Date()
        
        if !config.isEntireDay {
            let startTime = config.startTime + Double(TimeZone.current.secondsFromGMT())
            let endTime = config.endTime + Double(TimeZone.current.secondsFromGMT())
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            if let hour = components.hour, let minutes = components.minute {
                var time = TimeInterval(hour) * TimeInterval.secondsPerHour
                time += TimeInterval(minutes) * TimeInterval.secondsPerMinute
                
                if time < startTime || time > endTime {
                    return
                }
            }
        }
        
        guard config.snoozedUntilDate < date else { return }
        
        let content = createContentForNotification(ofType: type)
        
        let request = UNNotificationRequest(
            identifier: type.alertID,
            content: content,
            trigger: nil
        )
        
        let sound = settings.getSound(for: type)
        AudioController.shared.playSoundFile(sound.fileName)
        
        if settings.getIsVibrating(for: type) {
            AudioController.shared.vibrate()
        }
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error {
                LogController.log(
                    message: "Error while add notification request to a queue",
                    type: .error,
                    error: error
                )
            }
        })
    }
    
    func scheduleSnoozeForNotification(ofType type: AlertEventType) {
        guard let alertSettings = User.current.settings.alert else { return }
        
        var date = Date()
        let config = alertSettings.customConfiguration(for: type)
        if config.isOverriden,
            config.defaultSnooze > 0 {
            date = Date().addingTimeInterval(config.defaultSnooze)
        } else if let defaultConfig = alertSettings.defaultConfiguration,
            defaultConfig.defaultSnooze > 0 {
            date = Date().addingTimeInterval(defaultConfig.defaultSnooze)
        }
        config.updateSnoozedUntilDate(date)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [type.alertID])
    }
    
    func isNotificationSnoozed(ofType type: AlertEventType) -> Bool {
        guard let settings = User.current.settings.alert else { return false }
        let config = settings.customConfiguration(for: type)
        return config.snoozedUntilDate >= Date()
    }
    
    private func createContentForNotification(ofType type: AlertEventType) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = type.alertTitle
        content.body = type.alertBody
        content.sound = nil
        content.categoryIdentifier = defaultCategoryID
        content.badge = 0
        
        if let alert = User.current.settings.alert {
            let configuration = alert.customConfiguration(for: type)
            if configuration.isOverriden {
                if let name = configuration.name {
                    content.title = name
                }
                
                if configuration.snoozeFromNotification {
                    content.categoryIdentifier = snoozableNotificationCategoryID
                } else {
                    content.categoryIdentifier = defaultCategoryID
                }
            } else if let defaultConfig = alert.defaultConfiguration {
                if defaultConfig.snoozeFromNotification {
                    content.categoryIdentifier = snoozableNotificationCategoryID
                } else {
                    content.categoryIdentifier = defaultCategoryID
                }
            }
        }
        
        return content
    }
    
    func sendSuccessfulConnectionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "notification_transmitter_connection_title".localized
        content.body = "notification_transmitter_connection_body".localized
        content.sound = .default
        content.categoryIdentifier = defaultCategoryID
        content.badge = 0
        
        let request = UNNotificationRequest(
            identifier: "TransmitterConnectionAlert",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                LogController.log(
                    message: "Error while add notification request to a queue",
                    type: .error,
                    error: error
                )
            }
        }
    }
    
    func sendNotification(text: String) {
        let content = UNMutableNotificationContent()
        content.title = text
        content.body = text
        content.sound = .default
        content.categoryIdentifier = defaultCategoryID
        content.badge = 0
        
        let request = UNNotificationRequest(
            identifier: "Reading",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                LogController.log(
                    message: "Error while add notification request to a queue",
                    type: .error,
                    error: error
                )
            }
        }
    }
    
    func removeAppStoppedNotificationFromQueue() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["AppStoppedAlert"])
    }
    
    func addAppStoppedNotificationToQueue() {
        let content = UNMutableNotificationContent()
        content.title = "notification_app_stopped_title".localized
        content.body = "notification_app_stopped_body".localized
        content.sound = .default
        content.categoryIdentifier = defaultCategoryID
        content.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: .minutes(7), repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "AppStoppedAlert",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                LogController.log(
                    message: "Error while add notification request to a queue",
                    type: .error,
                    error: error
                )
            }
        }
    }
    
    private func canSendNotification(ofType type: AlertEventType) -> Bool {
        if AlertEventType.postponableAlerts.contains(type) {
            guard alertSkipCount[type] == 0 else {
                alertSkipCount[type]? -= 1
                return false
            }
            alertSentCount[type]? += 1
            alertSkipCount[type] = fibonacci(alertSentCount[type] ?? 0) - 1
        }
        
        return true
    }
    
    private func fibonacci(_ number: Int) -> Int {
        if number == 0 || number == 1 {
            return 1
        }
        
        var array = [Int]()
        array.append(1)
        array.append(1)
        
        var index = 2
        while index <= number {
            array.append(array[index - 1] + array[index - 2])
            index += 1
        }
        
        return array[number]
    }
}

extension NotificationController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        
        if response.notification.request.content.categoryIdentifier == "SnoozableNotification" {
            switch response.actionIdentifier {
            case "snooze_action":
                if let alertType = AlertEventType.allCases.first(where: { $0.alertID == identifier }) {
                    NotificationController.shared.scheduleSnoozeForNotification(ofType: alertType)
                }
            default:
                break
            }
        }
        
        completionHandler()
    }
}

extension Notification.Name {
    static let regularCalibrationCreated = Notification.Name("RegularCalibrationCreated")
}

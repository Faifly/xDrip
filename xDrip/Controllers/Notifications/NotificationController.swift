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
    private var calibrationsObserver: NSObjectProtocol?
    
    private var notAliveNotificationTimer: Timer?
    
    override private init() {
        super.init()
        setupNotificationObservers()
        
        addAppStoppedNotificationToQueue()
        notAliveNotificationTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(minutes: 9),
            repeats: true,
            block: { [weak self] _ in
                self?.removeAppStoppedNotificationFromQueue()
                self?.addAppStoppedNotificationToQueue()
            }
        )
    }
    
    deinit {
        CGMController.shared.unsubscribeFromGlucoseDataEvents(listener: self)
        calibrationsObserver = nil
    }
    
    func requestAuthorization() {
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
    
    private func setupCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "snooze_action",
            title: "Snooze",
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
        
        calibrationsObserver = NotificationCenter.default.addObserver(
            forName: .regularCalibrationCreated,
            object: nil,
            queue: nil,
            using: { [weak self] _ in
                self?.alertSentCount[.calibrationRequest] = 0
                self?.alertSkipCount[.calibrationRequest] = 0
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
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: .minutes(10), repeats: false)
        
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

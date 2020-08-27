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
    
    override private init() {
        super.init()
        glucoseNotificationWorker.notificationRequest = { [weak self] alertType in
            guard let self = self else { return }
            self.sendNotification(ofType: alertType)
        }
        
        UNUserNotificationCenter.current().delegate = self
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
    
    func sendNotification(ofType type: AlertEventType) {
        guard let settings = User.current.settings.alert, settings.isNotificationsEnabled else { return }
        let config = settings.customConfiguration(for: type)
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
        if config.isEnabled,
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
            if configuration.isEnabled {
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

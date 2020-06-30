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
    
    override init() {
        super.init()
        
        glucoseNotificationWorker.notificationRequest = { [weak self] alertType in
            guard let self = self else { return }
            self.sendNotification(ofType: alertType)
        }
    }
    
    func requestAuthorization() {
        var options: UNAuthorizationOptions = [
            .alert,
            .badge,
            .sound
        ]
        
        if #available(iOS 12.0, *) {
            options.update(with: .criticalAlert)
        }
        
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
        
        guard config.snoozedUntilDate < Date() else { return }
        
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
    
    private func createContentForNotification(ofType type: AlertEventType) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = type.alertTitle
        content.body = type.alertBody
        content.sound = nil
        content.categoryIdentifier = defaultCategoryID
        content.badge = 1
        
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

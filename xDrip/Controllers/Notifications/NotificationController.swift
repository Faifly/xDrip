//
//  NotificationController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationController {
    private static let defaultCategoryID = "AlertEvent"
    private static let snoozableNotificationCategoryID = "SnoozableNotification"
    
    static func requestAuthorization() {
        var options: UNAuthorizationOptions = [
            .alert,
            .badge,
            .sound
        ]
        
        if #available(iOS 12.0, *) {
            options.update(with: .criticalAlert)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                LogController.log(message: "Error while request notification authorization", type: .error, error: error)
            }
            
            if granted {
                setupCategories()
            }
        }
    }
    
    private static func setupCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: "snooze_action",
            title: "Snooze",
            options: .authenticationRequired
        )
        
        let alertEventCategory = UNNotificationCategory(
            identifier: "SnoozableNotification",
            actions: [snoozeAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([alertEventCategory])
    }
    
    static func sendNotification(ofType type: AlertEventType) {
        let content = createContentForNotification(ofType: type)
        
        let request = UNNotificationRequest(
            identifier: type.alertID,
            content: content,
            trigger: nil
        )
        
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
    
    static func scheduleSnoozeForNotification(ofType type: AlertEventType) {
        guard
            let alertSettings = User.current.settings.alert,
            let defaultConfig = alertSettings.defaultConfiguration
        else {
            return
        }
        
        let content = createContentForNotification(ofType: type)
        
        var trigger: UNNotificationTrigger?
        
        if defaultConfig.defaultSnooze > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: defaultConfig.defaultSnooze, repeats: false)
        }
        
        if let config = alertSettings.getCustomConfiguration(for: type),
            config.isEnabled,
            config.defaultSnooze > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: config.defaultSnooze, repeats: false)
        }
        
        let request = UNNotificationRequest(
            identifier: type.alertID,
            content: content,
            trigger: trigger
        )
        
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
    
    private static func createContentForNotification(ofType type: AlertEventType) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = type.alertTitle
        content.body = type.alertBody
        content.sound = nil
        content.categoryIdentifier = defaultCategoryID
        content.badge = 1
        
        if let alert = User.current.settings.alert {
//            var sound: UNNotificationSound = .default
            
            if let defaultConfig = alert.defaultConfiguration {
//                sound = getSound(for: defaultConfig.soundID)
                
                if let snd = CustomSound(rawValue: defaultConfig.soundID) {
                    content.userInfo["soundFileName"] = snd.fileName
                }
                
                if defaultConfig.snoozeFromNotification {
                    content.categoryIdentifier = snoozableNotificationCategoryID
                } else {
                    content.categoryIdentifier = defaultCategoryID
                }
            }
            
            if let conf = alert.getCustomConfiguration(for: type), conf.isEnabled {
                if let name = conf.name {
                    content.title = name
                }
                
//                sound = getSound(for: conf.soundID)
                
                if let snd = CustomSound(rawValue: conf.soundID) {
                    content.userInfo["soundFileName"] = snd.fileName
                }
                
                if conf.snoozeFromNotification {
                    content.categoryIdentifier = snoozableNotificationCategoryID
                } else {
                    content.categoryIdentifier = defaultCategoryID
                }
            }
            
//            content.sound = sound
            
            content.userInfo["isMuteOverriden"] = alert.isMuteOverriden
            content.userInfo["isSystemVolumeOverriden"] = alert.isSystemVolumeOverriden
            content.userInfo["overridenVolume"] = alert.volume
        }
        
        return content
    }
    
    private static func getSound(for soundID: Int) -> UNNotificationSound {
        var sound: UNNotificationSound = .default
        
        if let alert = User.current.settings.alert {
            if let customSound = CustomSound(rawValue: soundID) {
                sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: customSound.fileName))
                
                if alert.isMuteOverriden {
                    if #available(iOS 12.0, *) {
                        sound = .criticalSoundNamed(
                            UNNotificationSoundName(rawValue: customSound.fileName),
                            withAudioVolume: 1.0
                        )
                    }
                }
            }
        }
        
        return sound
    }
}

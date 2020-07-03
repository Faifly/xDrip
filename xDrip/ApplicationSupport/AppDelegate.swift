//
//  AppDelegate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import UserNotifications

// swiftlint:disable discouraged_optional_collection
@UIApplicationMain final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationLaunchController.runAppLaunchSequence()
        window = ApplicationLaunchController.createWindow()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    #if targetEnvironment(macCatalyst)
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if options.userActivities.first?.activityType == DebugController.debugLogWindowID {
            return UISceneConfiguration(
                name: DebugController.debugLogWindowID,
                sessionRole: connectingSceneSession.role
            )
        } else {
            return UISceneConfiguration(
                name: "Default Configuration",
                sessionRole: connectingSceneSession.role
            )
        }
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        MacMenuController.buildMenu(builder)
    }
    #endif
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
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

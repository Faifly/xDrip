//
//  AppDelegate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import UserNotifications
import AVKit

// swiftlint:disable discouraged_optional_collection

@UIApplicationMain final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private var player: AVAudioPlayer?
    private var task = UIBackgroundTaskIdentifier(rawValue: 0)
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ApplicationLaunchController.runAppLaunchSequence()
        window = ApplicationLaunchController.createWindow()
        UNUserNotificationCenter.current().delegate = self
        
        application.applicationIconBadgeNumber = 0
        
        setupTask()
        
        return true
    }
    
    // MARK: Setup background task for endless background mode
    private func setupTask() {
        task = UIApplication.shared.beginBackgroundTask(withName: "silence_sound_task") { [weak self] in
            self?.restartTask()
        }
        
        do {
            guard let path = Bundle.main.path(forResource: "500ms-of-silence", ofType: ".mp3") else { return }
            let url = URL(fileURLWithPath: path)
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
        } catch {
            LogController.log(message: "Cannot instantiate audioPlayer", type: .error, error: error)
        }

        player?.play()
    }
    
    func restartTask() {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
        setupTask()
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

// MARK: - AVAudioPlayerDelegate
extension AppDelegate: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        restartTask()
    }
}

//
//  ApplicationLaunchController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 05.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import RealmSwift
#if !targetEnvironment(macCatalyst)
import FirebaseCore
private let backgroundPlayer = BackgroundPlayer()
#endif

enum ApplicationLaunchController {
    static func runAppLaunchSequence() {
        _ = AudioController.shared
        #if !targetEnvironment(macCatalyst)
        FirebaseApp.configure()
//        backgroundPlayer.startBackgroundTask()
        #endif
        setupRealm()
        setupDevice()
        NotificationController.shared.setupService()
        _ = NightscoutService.shared
    }
    
    static func createWindow() -> UIWindow {
        let window = UIWindow()
        window.rootViewController = RootViewController()
        if #available(iOS 13.0, *) {} else {
            window.makeKeyAndVisible()
        }
        return window
    }
    
    private static func setupRealm() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 5,
            migrationBlock: { _, _ in },
            deleteRealmIfMigrationNeeded: false
        )
    }
    
    private static func setupDevice() {
        if let deviceType = CGMDevice.current.deviceType, !CGMDevice.current.isSetupInProgress {
            CGMController.shared.setupService(for: deviceType)
        }
    }
}

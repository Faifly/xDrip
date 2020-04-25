//
//  Settings+Notifications.swift
//  xDrip
//
//  Created by Ivan Skoryk on 16.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import UIKit

extension NotificationCenter {
    enum Setting {
        case unit
    }
    
    func subscribe(forSettingsChange settings: [Setting], notificationHandler: @escaping () -> Void) -> [NSObjectProtocol] {
        let handler: (Notification) -> Void = { _ in
            notificationHandler()
        }
        
        return settings.map { addObserver(forName: $0.notificationName, object: nil, queue: nil, using: handler) }
    }
    
    func postSettingsChangeNotification(setting: Setting) {
        post(name: setting.notificationName, object: nil)
    }
}

fileprivate extension NotificationCenter.Setting {
    var notificationName: Notification.Name {
        let name: String
        switch self {
        case .unit: name = "settingsUnit"
        }
        return Notification.Name(name)
    }
}
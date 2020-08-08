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
    enum Setting: CaseIterable {
        case unit
        case chart
        case deviceMode
        case injectionType
        case followerAuthStatus
        case sensorStarted
        
        case basalRelated
        case activeInsulin
        case activeCarbs
        case alertRepeat
        case fastRise
        case fastDrop
        case urgentHigh
        case urgentLow
        case high
        case low
        case warmUp
    }
    
    func subscribe(forSettingsChange settings: [Setting],
                   notificationHandler: @escaping () -> Void) -> [NSObjectProtocol] {
        let handler: (Notification) -> Void = { _ in
            notificationHandler()
        }
        
        return settings.map { addObserver(forName: $0.notificationName, object: nil, queue: nil, using: handler) }
    }
    
    func subscribe(forSettingsChange settings: [Setting],
                   notificationHandler: @escaping (Setting) -> Void) -> [NSObjectProtocol] {
        let handler: (Notification) -> Void = { notification in
            if let setting = Setting.allCases.first(where: { $0.notificationName == notification.name }) {
                notificationHandler(setting)
            }
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
        case .chart: name = "settingsChart"
        case .deviceMode: name = "settingsDeviceMode"
        case .injectionType: name = "settingsInjectionType"
        case .followerAuthStatus: name = "followerAuthStatus"
        case .alertRepeat: name = "alertRepeat"
        case .fastRise: name = "repeatFastRise"
        case .fastDrop: name = "repeatFastDrop"
        case .urgentHigh: name = "repeatUrgentHigh"
        case .urgentLow: name = "repeatUrgentDrop"
        case .high: name = "repeatHigh"
        case .low: name = "repeatLow"
        case .sensorStarted: name = "sensorStarted"
        case .warmUp: name = "warmUp"
        case .basalRelated: name = "basalRelated"
        case .activeInsulin: name = "activeInsulin"
        case .activeCarbs: name = "activeCarbs"
        }
        return Notification.Name(name)
    }
}

//
//  AlertSettings.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class AlertSettings: Object {
    @objc private(set) dynamic var isSystemVolumeOverriden: Bool = false
    @objc private(set) dynamic var volume: Float = 0.0
    @objc private(set) dynamic var isMuteOverriden: Bool = false
    @objc private(set) dynamic var isNotificationsEnabled: Bool = true
    @objc private(set) dynamic var defaultConfiguration: AlertConfiguration?
    
    private let customConfigurations = List<AlertConfiguration>()
    
    required init() {
        super.init()
        defaultConfiguration = AlertConfiguration(eventType: .default)
    }
    
    func customConfiguration(for type: AlertEventType) -> AlertConfiguration {
        if let configuration = customConfigurations.first(where: { $0.eventType == type }) {
            return configuration
        } else {
            let configuration = AlertConfiguration(eventType: type)
            Realm.shared.safeWrite {
                customConfigurations.append(configuration)
            }
            return configuration
        }
    }
    
    func getSound(for type: AlertEventType) -> CustomSound {
        var sound = CustomSound.default
        
        let configuration = customConfiguration(for: type)
        if configuration.isOverriden, let snd = CustomSound(rawValue: configuration.soundID) {
            sound = snd
        } else if let defaultConfig = defaultConfiguration, let snd = CustomSound(rawValue: defaultConfig.soundID) {
            sound = snd
        }
        
        return sound
    }
    
    func getIsVibrating(for type: AlertEventType) -> Bool {
        var isVibrating = false
        
        let configuration = customConfiguration(for: type)
        if configuration.isOverriden {
            isVibrating = configuration.isVibrating
        } else if let defaultConfig = defaultConfiguration {
            isVibrating = defaultConfig.isVibrating
        }
        
        return isVibrating
    }
    
    func updateVolume(_ volume: Float) {
        Realm.shared.safeWrite {
            self.volume = volume
        }
    }
    
    func updateSystemVolumeOverriden(_ overriden: Bool) {
        Realm.shared.safeWrite {
            self.isSystemVolumeOverriden = overriden
        }
    }
    
    func updateMuteOverriden(_ overriden: Bool) {
        Realm.shared.safeWrite {
            self.isMuteOverriden = overriden
        }
    }
    
    func updateNotificationEnabled(_ enabled: Bool) {
        Realm.shared.safeWrite {
            self.isNotificationsEnabled = enabled
        }
    }
}

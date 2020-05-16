//
//  AlertConfiguration.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class AlertConfiguration: Object {
    @objc private(set) dynamic var isEnabled: Bool = false
    @objc private(set) dynamic var name: String?
    @objc private(set) dynamic var snoozeFromNotification: Bool = false
    @objc private(set) dynamic var defaultSnooze: TimeInterval = 0.0
    @objc private(set) dynamic var `repeat`: Bool = false
    @objc private(set) dynamic var soundID: Int = -1
    @objc private(set) dynamic var isVibrating: Bool = false
    @objc private(set) dynamic var isEntireDay: Bool = false
    @objc private(set) dynamic var startTime: TimeInterval = 0.0
    @objc private(set) dynamic var endTime: TimeInterval = 0.0
    @objc private(set) dynamic var highThreshold: Float = 0.0
    @objc private(set) dynamic var lowThreshold: Float = 0.0
    @objc private dynamic var rawEventType: Int = 0
    
    private(set) var eventType: AlertEventType {
        get {
            return AlertEventType(rawValue: rawEventType) ?? .default
        }
        set {
            rawEventType = newValue.rawValue
        }
    }
    
    required init(eventType: AlertEventType) {
        super.init()
        self.eventType = eventType
    }
    
    required init() {
        super.init()
    }
    
    func updateIsEnabled(_ isEnabled: Bool) {
        Realm.shared.safeWrite {
            self.isEnabled = isEnabled
        }
    }
    
    func updateName(_ name: String?) {
        Realm.shared.safeWrite {
            self.name = name
        }
    }
    
    func updateSnoozeFromNotification(_ snooze: Bool) {
        Realm.shared.safeWrite {
            self.snoozeFromNotification = snooze
        }
    }
    
    func updateDefaultSnooze(_ snooze: TimeInterval) {
        Realm.shared.safeWrite {
            self.defaultSnooze = snooze
        }
    }
    
    func updateRepeat(_ repeats: Bool) {
        Realm.shared.safeWrite {
            self.repeat = repeats
        }
    }
    
    func updateSoundID(_ identifier: Int) {
        Realm.shared.safeWrite {
            self.soundID = identifier
        }
    }
    
    func updateIsVibrating(_ isVibrating: Bool) {
        Realm.shared.safeWrite {
            self.isVibrating = isVibrating
        }
    }
    
    func updateIsEntireDay(_ isEntireDay: Bool) {
        Realm.shared.safeWrite {
            self.isEntireDay = isEntireDay
        }
    }
    
    func updateStartTime(_ startTime: TimeInterval) {
        Realm.shared.safeWrite {
            self.startTime = startTime
        }
    }
    
    func updateEndTime(_ endTime: TimeInterval) {
        Realm.shared.safeWrite {
            self.endTime = endTime
        }
    }
    
    func updateHighThreshold(_ threshold: Float) {
        Realm.shared.safeWrite {
            self.highThreshold = threshold
        }
    }
    
    func updateLowThreshold(_ threshold: Float) {
        Realm.shared.safeWrite {
            self.lowThreshold = threshold
        }
    }
    
    func updateEventType(_ eventType: AlertEventType) {
        Realm.shared.safeWrite {
            self.eventType = eventType
        }
    }
}

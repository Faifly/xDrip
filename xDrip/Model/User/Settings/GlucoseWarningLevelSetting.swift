//
//  GlucoseWarningLevelSetting.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class GlucoseWarningLevelSetting: Object {
    @objc private dynamic var rawWarningLevel: Int = 0
    @objc private(set) dynamic var value: Double = 0
    
    init(level: GlucoseWarningLevel, value: Double) {
        super.init()
        self.warningLevel = level
        self.value = value
    }
    
    required init() {
        super.init()
    }
    
    private(set) var warningLevel: GlucoseWarningLevel {
        get {
            return GlucoseWarningLevel(rawValue: rawWarningLevel) ?? .low
        }
        set {
            rawWarningLevel = newValue.rawValue
        }
    }
    
    func updateValue(_ value: Double) {
        Realm.shared.safeWrite {
            self.value = value
        }
    }
}

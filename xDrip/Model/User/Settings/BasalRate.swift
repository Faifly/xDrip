//
//  BasalRate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class BasalRate: Object {
    @objc private(set) dynamic var startTime: TimeInterval = 0.0
    @objc private(set) dynamic var units: Float = 0.0
    
    convenience init(startTime: TimeInterval, units: Float) {
        self.init()
        self.startTime = startTime
        self.units = units
    }
    
    func update(withStartTime startTime: TimeInterval, units: Float) {
        Realm.shared.safeWrite {
            self.startTime = startTime
            self.units = units
        }
    }
    
    static var minMax: Range<Float> {
        return 0.0 ..< 35.0
    }
    
    static var unitStep: Float {
        return 0.05
    }
}

//
//  CalibrationEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class CalibrationEntry: AbstractEntry {
    @objc private(set) dynamic var firstValue: Double = 0.0
    @objc private(set) dynamic var secondValue: Double = 0.0
    
    required init() {
        super.init()
    }
    
    init(firstValue: Double, secondValue: Double, date: Date) {
        super.init(date: date)
        self.firstValue = firstValue
        self.secondValue = secondValue
    }
    
    func update(firstValue: Double, secondValue: Double, date: Date) {
        Realm.shared.safeWrite {
            self.firstValue = firstValue
            self.secondValue = secondValue
            self.updateDate(date)
        }
    }
}

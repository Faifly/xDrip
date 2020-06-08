//
//  BolusEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class BolusEntry: AbstractEntry {
    @objc private(set) dynamic var amount: Double = 0.0
    
    required init() {
        super.init()
    }
    
    init(amount: Double, date: Date) {
        super.init(date: date)
        self.amount = amount
    }
    
    func update(amount: Double, date: Date) {
        Realm.shared.safeWrite {
            self.amount = amount
            self.updateDate(date)
        }
    }
    
    func updateAmount(_ amount: Double) {
        self.amount = amount
    }
}

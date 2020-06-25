//
//  BolusEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class BolusEntry: AbstractEntry, BaseChartEntry {
    var date: Date {
        return super.entryDate ?? Date()
    }
    
    @objc private(set) dynamic var value: Double = 0.0
    
    required init() {
        super.init()
    }
    
    init(amount: Double, date: Date) {
        super.init(date: date)
        self.value = amount
    }
    
    func update(amount: Double, date: Date) {
        Realm.shared.safeWrite {
            self.value = amount
            self.updateDate(date)
        }
    }
}

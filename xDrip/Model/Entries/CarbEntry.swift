//
//  CarbEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class CarbEntry: AbstractEntry {
    @objc private(set) dynamic var amount: Double = 0.0
    @objc private(set) dynamic var foodType: String?
    @objc private(set) dynamic var assimilationDuration: TimeInterval = 0.0
    
    init(amount: Double, foodType: String?, assimilationDuration: TimeInterval, date: Date) {
        super.init(date: date)
        self.amount = amount
        self.foodType = foodType
        self.assimilationDuration = assimilationDuration
    }
    
    required init() {
        super.init()
    }
    
    func update(amount: Double, foodType: String?, assimilationDuration: TimeInterval, date: Date) {
        Realm.shared.safeWrite {
            self.amount = amount
            self.foodType = foodType
            self.assimilationDuration = assimilationDuration
            self.updateDate(date)
        }
    }
    
    func updateAmount(_ amount: Double) {
        self.amount = amount
    }
    
    func updateFoodType(_ foodType: String?) {
        self.foodType = foodType
    }
}

//
//  InsulinEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class InsulinEntry: AbstractEntry, AbstractEntryProtocol {
    @objc private(set) dynamic var amount: Double = 0.0
    @objc private dynamic var rawType: Int = InsulinType.bolus.rawValue
    
    var type: InsulinType {
        get {
            return InsulinType(rawValue: rawType) ?? .bolus
        }
        set {
            rawType = newValue.rawValue
        }
    }
    
    required init() {
        super.init()
    }
    
    init(amount: Double, date: Date, type: InsulinType) {
        super.init(date: date)
        self.amount = amount
        self.type = type
    }
    
    func update(amount: Double, date: Date) {
        Realm.shared.safeWrite {
            self.amount = amount
            self.updateDate(date)
        }
        
        switch type {
        case .bolus:
            InsulinEntriesWorker.updatedBolusEntry()
        case .basal:
            InsulinEntriesWorker.updatedBasalEntry()
        }
    }
}

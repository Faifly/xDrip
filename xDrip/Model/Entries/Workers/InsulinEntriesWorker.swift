//
//  InsulinEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 05.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class InsulinEntriesWorker: AbstractEntriesWorker {
    @discardableResult static func addBolusEntry(amount: Double, date: Date) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .bolus)
        return add(entry: entry)
    }
    
    static func fetchAllBolusEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self).filter { $0.type == .bolus }
    }
    
    @discardableResult static func addBasalEntry(amount: Double, date: Date) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .basal)
        add(entry: entry)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "basalEntryAdded"), object: nil)
        
        return entry
    }
    
    static func fetchAllBasalEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self).filter { $0.type == .basal }
    }
    
    static func fetchAllInsulinEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self)
    }
}

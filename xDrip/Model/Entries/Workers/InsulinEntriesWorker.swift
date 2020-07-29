//
//  InsulinEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 05.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AKUtils

final class InsulinEntriesWorker: AbstractEntriesWorker {
    static var insulinDataHandler: (() -> Void)?
    
    @discardableResult static func addBolusEntry(amount: Double, date: Date) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .bolus)
        let addedEntry = add(entry: entry)
        insulinDataHandler?()
        return addedEntry
    }
    
    @discardableResult static func addBasalEntry(amount: Double, date: Date) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .basal)
        add(entry: entry)
        
        return entry
    }
    
    static func deleteBolusEntry(_ entry: AbstractEntry) {
        super.deleteEntry(entry)
        insulinDataHandler?()
    }
    
    static func fetchAllBolusEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self).filter { $0.type == .bolus }
    }
    
    static func fetchAllBasalEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self).filter { $0.type == .basal }
    }
    
    static func fetchAllInsulinEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self)
    }
    
    static func updatedInsulinEntry() {
        insulinDataHandler?()
    }
}

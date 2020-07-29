//
//  FoodEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

//protocol FoodEntriesWorkerProtocol: AnyObject {
//    static var bolusDataHandler: (() -> Void)? { get set }
//    static var carbsDataHandler: (() -> Void)? { get set }
//    static func fetchAllBolusEntries() -> [InsulinEntry]
//    static func fetchAllCarbEntries() -> [CarbEntry]
//}

final class FoodEntriesWorker: AbstractEntriesWorker {
    static var bolusDataHandler: (() -> Void)?
    static var carbsDataHandler: (() -> Void)?
    
    @discardableResult static func addCarbEntry(
        amount: Double,
        foodType: String?,
        date: Date) -> CarbEntry {
        let entry = CarbEntry(
            amount: amount,
            foodType: foodType,
            date: date
        )
        let addedEntry = add(entry: entry)
        carbsDataHandler?()
        return addedEntry
    }
    
    @discardableResult static func addBolusEntry(amount: Double, date: Date) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .bolus)
        let addedEntry = add(entry: entry)
        bolusDataHandler?()
        return addedEntry
    }
    
    static func fetchAllCarbEntries() -> [CarbEntry] {
        return super.fetchAllEntries(type: CarbEntry.self)
    }
    
    static func fetchAllBolusEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self)
    }
    
    static func deleteBolusEntry(_ entry: AbstractEntry) {
        super.deleteEntry(entry)
        bolusDataHandler?()
    }
    
    static func deleteCarbsEntry(_ entry: AbstractEntry) {
        super.deleteEntry(entry)
        carbsDataHandler?()
    }
    
    static func updatedBolusEntry() {
        bolusDataHandler?()
    }
    
    static func updatedCarbsEntry() {
        carbsDataHandler?()
    }
}

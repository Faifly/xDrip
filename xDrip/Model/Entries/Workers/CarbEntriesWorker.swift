//
//  FoodEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class CarbEntriesWorker: AbstractEntriesWorker {
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
    
    static func deleteCarbsEntry(_ entry: AbstractEntry) {
        super.deleteEntry(entry)
        carbsDataHandler?()
    }
    
    static func fetchAllCarbEntries() -> [CarbEntry] {
        return super.fetchAllEntries(type: CarbEntry.self)
    }
    
    static func updatedCarbsEntry() {
        carbsDataHandler?()
    }
}
//
//  FoodEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class FoodEntriesWorker: AbstractEntriesWorker {
    @discardableResult static func addCarbEntry(
        amount: Double,
        foodType: String?,
        assimilationDuration: TimeInterval,
        date: Date) -> CarbEntry {
        let entry = CarbEntry(
            amount: amount,
            foodType: foodType,
            assimilationDuration: assimilationDuration,
            date: date
        )
        return add(entry: entry)
    }
    
    @discardableResult static func addBolusEntry(amount: Double, date: Date) -> BolusEntry {
        let entry = BolusEntry(amount: amount, date: date)
        return add(entry: entry)
    }
    
    static func fetchAllCarbEntries() -> [CarbEntry] {
        return super.fetchAllEntries(type: CarbEntry.self)
    }
    
    static func fetchAllBolusEntries() -> [BolusEntry] {
        return super.fetchAllEntries(type: BolusEntry.self)
    }
}

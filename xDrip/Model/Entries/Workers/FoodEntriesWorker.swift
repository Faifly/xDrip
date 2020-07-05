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
        date: Date) -> CarbEntry {
        let entry = CarbEntry(
            amount: amount,
            foodType: foodType,
            date: date
        )
        return add(entry: entry)
    }
    
    static func fetchAllCarbEntries() -> [CarbEntry] {
        return super.fetchAllEntries(type: CarbEntry.self)
    }
}

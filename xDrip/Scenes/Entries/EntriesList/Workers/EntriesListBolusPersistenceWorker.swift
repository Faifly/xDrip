//
//  EntriesListBolusPersistenceWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListBolusPersistenceWorker: EntriesListEntryPersistenceWorker {
    private var bolusEntries: [BolusEntry] = []
    
    func fetchEntries() -> [AbstractEntry] {
        bolusEntries = FoodEntriesWorker.fetchAllBolusEntries()
        return bolusEntries
    }

    func deleteEntry(_ index: Int) {
        let entry = bolusEntries.remove(at: index)
        FoodEntriesWorker.deleteEntry(entry)
    }
}

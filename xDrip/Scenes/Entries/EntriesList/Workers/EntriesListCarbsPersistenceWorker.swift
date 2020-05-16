//
//  EntriesListCarbsPersistenceWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListCarbsPersistenceWorker: EntriesListEntryPersistenceWorker {
    private var carbs: [CarbEntry] = []
    
    func fetchEntries() -> [AbstractEntry] {
        carbs = []
        
        for _ in 0 ... 20 {
            let randValue = Double.random(in: 0...100)
            let randomTimeInterval = TimeInterval.random(in: 0 ... 1_000_000_000)
            let date = Date(timeIntervalSince1970: randomTimeInterval)
            
            let entry = CarbEntry(
                amount: randValue,
                foodType: nil,
                assimilationDuration: 0.0,
                date: date
            )
            carbs.append(entry)
        }
        
        return carbs
    }

    func deleteEntry(_ index: Int) {
        _ = carbs.remove(at: index)
        
        // add delete from database
    }
}

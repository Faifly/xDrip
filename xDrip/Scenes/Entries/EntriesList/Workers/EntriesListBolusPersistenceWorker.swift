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
        bolusEntries = []
        
        for _ in 0 ... 20 {
            let randValue = Double.random(in: 0...100)
            let randomTimeInterval = TimeInterval.random(in: 0 ... 1_000_000_000)
            let date = Date(timeIntervalSince1970: randomTimeInterval)
            
            let entry = BolusEntry(amount: randValue, date: date)
                bolusEntries.append(entry)
        }
        
        return bolusEntries
    }

    func deleteEntry(_ index: Int) {
        let entry = bolusEntries.remove(at: index)
        
        // add delete from database
    }
}

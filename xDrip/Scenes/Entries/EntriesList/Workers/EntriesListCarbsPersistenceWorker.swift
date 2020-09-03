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
        carbs = CarbEntriesWorker.fetchAllCarbEntries().filter { $0.cloudUploadStatus != .waitingForDeletion }
        return carbs
    }

    func deleteEntry(_ index: Int) {
        let entry = carbs.remove(at: index)
        CarbEntriesWorker.deleteCarbsEntry(entry)
    }
}

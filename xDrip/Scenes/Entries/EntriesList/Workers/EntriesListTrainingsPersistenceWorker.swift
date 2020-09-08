//
//  EntriesListTrainingsPersistenceWorker.swift
//  xDrip
//
//  Created by Dmitry on 04.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListTrainingsPersistenceWorker: EntriesListEntryPersistenceWorker {
    private var trainings: [TrainingEntry] = []
    
    func fetchEntries() -> [AbstractEntry] {
        trainings = TrainingEntriesWorker.fetchAllTrainings()
        return trainings
    }

    func deleteEntry(_ index: Int) {
        let entry = trainings.remove(at: index)
        TrainingEntriesWorker.deleteTrainingEntry(entry)
    }
}

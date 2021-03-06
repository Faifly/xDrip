//
//  TrainingEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class TrainingEntriesWorker: AbstractEntriesWorker {
    static var trainingDataHandler: (() -> Void)?
    
    @discardableResult static func addTraining(
        duration: TimeInterval,
        intensity: TrainingIntensity,
        date: Date,
        externalID: String? = nil) -> TrainingEntry {
        let entry = TrainingEntry(duration: duration,
                                  intensity: intensity,
                                  date: date,
                                  externalID: externalID)
        let addedEntry = add(entry: entry)
        NightscoutService.shared.scanForNotUploadedTreatments()
        return addedEntry
    }
    
    static func fetchAllTrainings() -> [TrainingEntry] {
        return super.fetchAllEntries(type: TrainingEntry.self)
    }
    
    static func deleteTrainingEntry(_ entry: TrainingEntry) {
        if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            entry.updateCloudUploadStatus(.waitingForDeletion)
        } else {
            super.deleteEntry(entry)
        }
        trainingDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func updatedTrainingEntry() {
        trainingDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func deleteEntryWith(externalID: String) {
        guard let entry = fetchAllTrainings().first(where: { $0.externalID == externalID }) else {
            return
        }
        super.deleteEntry(entry)
    }
    
    static func markEntryAsUploaded(externalID: String) {
        guard let entry = fetchAllTrainings().first(where: { $0.externalID == externalID }) else {
            return
        }
        entry.updateCloudUploadStatus(.uploaded)
    }
}

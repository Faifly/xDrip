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
    
    static func fetchAllTrainings(mode: UserDeviceMode? = nil) -> [TrainingEntry] {
        let entries = super.fetchAllEntries(type: TrainingEntry.self)
            .filter(.deviceMode(mode: mode ?? User.current.settings.deviceMode))
        return Array(entries)
    }
    
    static func deleteTrainingEntry(_ entry: TrainingEntry) {
        entry.updateCloudUploadStatus(.waitingForDeletion)
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
    
    static func deleteAllEntries(mode: UserDeviceMode, filter: NSPredicate? = nil) {
        super.deleteAllEntries(type: TrainingEntry.self, mode: mode, filter: filter)
        trainingDataHandler?()
    }
}

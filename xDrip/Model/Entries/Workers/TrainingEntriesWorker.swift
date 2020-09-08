//
//  TrainingEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class TrainingEntriesWorker: AbstractEntriesWorker {
    @discardableResult static func addTraining(
        duration: TimeInterval,
        intensity: TrainingIntensity,
        date: Date,
        externalID: String? = nil) -> TrainingEntry {
        let entry = TrainingEntry(duration: duration,
                                  intensity: intensity,
                                  date: date,
                                  externalID: externalID)
        if externalID != nil {
            entry.cloudUploadStatus = .uploaded
        } else if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            entry.cloudUploadStatus = .notUploaded
        }
        let addedEntry = add(entry: entry)
        NightscoutService.shared.scanForNotUploadedTreatments()
        return addedEntry
    }
    
    static func fetchAllTrainings() -> [TrainingEntry] {
        return super.fetchAllEntries(type: TrainingEntry.self)
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
        Realm.shared.safeWrite {
            entry.cloudUploadStatus = .uploaded
        }
    }
}

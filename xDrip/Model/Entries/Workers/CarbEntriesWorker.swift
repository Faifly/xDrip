//
//  FoodEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation


final class CarbEntriesWorker: AbstractEntriesWorker {
    static var carbsDataHandler: (() -> Void)?
    
    @discardableResult static func addCarbEntry(
        amount: Double,
        foodType: String?,
        date: Date,
        externalID: String? = nil) -> CarbEntry {
        let entry = CarbEntry(
            amount: amount,
            foodType: foodType,
            date: date,
            externalID: externalID
        )
        if externalID != nil {
            entry.cloudUploadStatus = .uploaded
        } else if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            entry.cloudUploadStatus = .notUploaded
        }
        let addedEntry = add(entry: entry)
        carbsDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
        return addedEntry
    }
    
    static func deleteCarbsEntry(_ entry: CarbEntry) {
        if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            entry.updateCloudUploadStatus(.waitingForDeletion)
        } else {
            super.deleteEntry(entry)
        }
        
        carbsDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func fetchAllCarbEntries() -> [CarbEntry] {
        return super.fetchAllEntries(type: CarbEntry.self)
    }
    
    static func updatedCarbsEntry() {
        carbsDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func deleteEntryWith(externalID: String) {
        guard let entry = fetchAllCarbEntries().first(where: { $0.externalID == externalID }) else {
            return
        }
        super.deleteEntry(entry)
    }
    
    static func markEntryAsUploaded(externalID: String) {
        guard let entry = fetchAllCarbEntries().first(where: { $0.externalID == externalID }) else {
            return
        }
        entry.updateCloudUploadStatus(.uploaded)
    }
}

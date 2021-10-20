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
            
            let addedEntry = add(entry: entry)
            carbsDataHandler?()
            NightscoutService.shared.scanForNotUploadedTreatments()
            return addedEntry
        }
    
    static func fetchAllCarbEntries(mode: UserDeviceMode? = nil) -> [CarbEntry] {
        let entries = super.fetchAllEntries(type: CarbEntry.self)
            .filter(.deviceMode(mode: mode ?? User.current.settings.deviceMode))
        return Array(entries)
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
    
    static func deleteCarbsEntry(_ entry: CarbEntry) {
        entry.updateCloudUploadStatus(.waitingForDeletion)
        carbsDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func deleteAllEntries(mode: UserDeviceMode, filter: NSPredicate? = nil) {
        super.deleteAllEntries(type: CarbEntry.self, mode: mode, filter: filter)
        carbsDataHandler?()
    }
    
    static func markEntryAsUploaded(externalID: String) {
        guard let entry = fetchAllCarbEntries().first(where: { $0.externalID == externalID }) else {
            return
        }
        entry.updateCloudUploadStatus(.uploaded)
    }
}

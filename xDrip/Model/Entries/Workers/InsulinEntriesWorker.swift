//
//  InsulinEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 05.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AKUtils

final class InsulinEntriesWorker: AbstractEntriesWorker {
    static var bolusDataHandler: (() -> Void)?
    static var basalDataHandler: (() -> Void)?
    
    @discardableResult static func addBolusEntry(amount: Double,
                                                 date: Date,
                                                 externalID: String? = nil) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .bolus, externalID: externalID)
        add(entry: entry)
        bolusDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
        return entry
    }
    
    @discardableResult static func addBasalEntry(amount: Double,
                                                 date: Date,
                                                 externalID: String? = nil) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .basal, externalID: externalID)
        add(entry: entry)
        basalDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
        return entry
    }
    
    static func deleteInsulinEntry(_ entry: InsulinEntry) {
        let type = entry.type
        entry.updateCloudUploadStatus(.waitingForDeletion)
        switch type {
        case .bolus:
            bolusDataHandler?()
        case .basal, .pumpBasal:
            basalDataHandler?()
        }
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func fetchAllBolusEntries(mode: UserDeviceMode? = nil) -> [InsulinEntry] {
        return fetchAllInsulinEntries(mode: mode).filter { $0.type == .bolus }
    }
    
    static func fetchAllBasalEntries(mode: UserDeviceMode? = nil) -> [InsulinEntry] {
        return fetchAllInsulinEntries(mode: mode).filter { $0.type == .basal }
    }
    
    static func fetchAllPumpBasalEntries(mode: UserDeviceMode? = nil) -> [InsulinEntry] {
        return fetchAllInsulinEntries(mode: mode).filter { $0.type == .pumpBasal }
    }
    
    static func fetchAllInsulinEntries(mode: UserDeviceMode? = nil) -> [InsulinEntry] {
        let entries = super.fetchAllEntries(type: InsulinEntry.self)
            .filter(.deviceMode(mode: mode ?? User.current.settings.deviceMode))
        return Array(entries)
    }
    
    static func updatedBolusEntry() {
        bolusDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func updatedBasalEntry() {
        basalDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func deleteEntryWith(externalID: String) {
        guard let entry = fetchAllInsulinEntries().first(where: { $0.externalID == externalID }) else {
            return
        }
        super.deleteEntry(entry)
    }
    
    static func markEntryAsUploaded(externalID: String) {
        guard let entry = fetchAllInsulinEntries().first(where: { $0.externalID == externalID }) else {
            return
        }
        entry.updateCloudUploadStatus(.uploaded)
    }
    
    static func deleteAllEntries(mode: UserDeviceMode, filter: NSPredicate? = nil) {
        super.deleteAllEntries(type: InsulinEntry.self, mode: mode, filter: filter)
        bolusDataHandler?()
        basalDataHandler?()
    }
}

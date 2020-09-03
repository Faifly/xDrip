//
//  InsulinEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 05.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AKUtils
import RealmSwift

final class InsulinEntriesWorker: AbstractEntriesWorker {
    static var bolusDataHandler: (() -> Void)?
    static var basalDataHandler: (() -> Void)?
    
    @discardableResult static func addBolusEntry(amount: Double, date: Date, externalID: String? = nil) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .bolus, externalID: externalID)
        if externalID != nil {
            entry.cloudUploadStatus = .uploaded
        } else if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            entry.cloudUploadStatus = .notUploaded
        }
        let addedEntry = add(entry: entry)
        bolusDataHandler?()
        NightscoutService.shared.scanForNotUploadedTreatments()
        return addedEntry
    }
    
    @discardableResult static func addBasalEntry(amount: Double, date: Date, externalID: String? = nil) -> InsulinEntry {
        let entry = InsulinEntry(amount: amount, date: date, type: .basal, externalID: externalID)
        if externalID != nil {
            entry.cloudUploadStatus = .uploaded
        } else if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            entry.cloudUploadStatus = .notUploaded
        }
        add(entry: entry)
        NotificationCenter.default.postSettingsChangeNotification(setting: .basalRelated)
        NightscoutService.shared.scanForNotUploadedTreatments()
        return entry
    }
    
    static func deleteInsulinEntry(_ entry: InsulinEntry) {
        let type = entry.type
        if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            Realm.shared.safeWrite {
                entry.cloudUploadStatus = .waitingForDeletion
            }
        } else {
            super.deleteEntry(entry)
        }
        
        if type == .bolus {
            bolusDataHandler?()
        } else if type == .basal {
            basalDataHandler?()
        }
        NightscoutService.shared.scanForNotUploadedTreatments()
    }
    
    static func fetchAllBolusEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self).filter { $0.type == .bolus }
    }
    
    static func fetchAllBasalEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self).filter { $0.type == .basal }
    }
    
    static func fetchAllInsulinEntries() -> [InsulinEntry] {
        return super.fetchAllEntries(type: InsulinEntry.self)
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
        Realm.shared.safeWrite {
            entry.cloudUploadStatus = .uploaded
        }
    }
}

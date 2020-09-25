//
//  InsulinEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class InsulinEntry: AbstractEntry, AbstractEntryProtocol, TreatmentEntryProtocol {
    @objc private(set) dynamic var amount: Double = 0.0
    @objc private dynamic var rawType: Int = InsulinType.bolus.rawValue
    @objc private(set) dynamic var duration: Double = 0.0
    
    var type: InsulinType {
        get {
            return InsulinType(rawValue: rawType) ?? .bolus
        }
        set {
            rawType = newValue.rawValue
        }
    }
    
    required init() {
        super.init()
    }
    
    init(amount: Double, date: Date, type: InsulinType, externalID: String? = nil) {
        super.init(date: date, externalID: externalID)
        self.amount = amount
        self.type = type
        if externalID != nil {
            self.cloudUploadStatus = .uploaded
        } else if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            self.cloudUploadStatus = .notUploaded
        }
    }
    
    func update(amount: Double, date: Date) {
        Realm.shared.safeWrite {
            self.amount = amount
            self.updateDate(date)
            if self.cloudUploadStatus == .uploaded {
                 self.cloudUploadStatus = .modified
             }
        }
        
        switch type {
        case .bolus:
            InsulinEntriesWorker.updatedBolusEntry()
        case .basal:
            InsulinEntriesWorker.updatedBasalEntry()
        }
    }
    
    func update(duration: Double) {
        Realm.shared.safeWrite {
            self.duration = duration
        }
    }
}

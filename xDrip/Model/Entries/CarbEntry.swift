//
//  CarbEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class CarbEntry: AbstractEntry, AbstractEntryProtocol, TreatmentEntryProtocol {
    @objc private(set) dynamic var amount: Double = 0.0
    @objc private(set) dynamic var foodType: String?
    @objc private(set) dynamic var assimilationDuration: TimeInterval = 0.0
    
    init(amount: Double, foodType: String?, date: Date, externalID: String? = nil) {
        super.init(date: date, externalID: externalID)
        self.amount = amount
        self.foodType = foodType
        if externalID != nil {
            self.cloudUploadStatus = .uploaded
        } else if let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments {
            self.cloudUploadStatus = .notUploaded
        }
    }
    
    required init() {
        super.init()
    }
    
    func update(amount: Double, foodType: String?, date: Date) {
        Realm.shared.safeWrite {
            self.amount = amount
            self.foodType = foodType
            self.updateDate(date)
            if self.cloudUploadStatus == .uploaded {
                 self.cloudUploadStatus = .modified
             }
        }
        CarbEntriesWorker.updatedCarbsEntry()
    }
}

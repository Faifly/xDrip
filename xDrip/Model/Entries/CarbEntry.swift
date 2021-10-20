//
//  CarbEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class CarbEntry: AbstractEntry, AbstractAbsorbableEntryProtocol, TreatmentEntryProtocol {
    @objc private(set) dynamic var amount: Double = 0.0
    @objc private(set) dynamic var foodType: String?
    @objc private(set) dynamic var absorptionDuration: TimeInterval = 0.0
    
    var treatmentAbsorptionTime: TimeInterval? {
        return absorptionDuration
    }
    
    init(amount: Double,
         foodType: String?,
         date: Date,
         externalID: String? = nil,
         absorptionDuration: TimeInterval? = nil) {
        super.init(date: date, externalID: externalID)
        self.amount = amount
        self.foodType = foodType
        self.absorptionDuration = absorptionDuration ?? User.current.settings.carbsAbsorptionRate
        if externalID != nil {
            self.cloudUploadStatus = .uploaded
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
            self.absorptionDuration = User.current.settings.carbsAbsorptionRate
            if self.cloudUploadStatus == .uploaded {
                 self.cloudUploadStatus = .modified
             }
        }
        CarbEntriesWorker.updatedCarbsEntry()
    }
}

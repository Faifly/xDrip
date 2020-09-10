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
    @objc private(set) dynamic var externalID: String?
    @objc private dynamic var rawCloudUploadStatus: Int = CloudUploadStatus.notApplicable.rawValue

    var cloudUploadStatus: CloudUploadStatus {
        get {
            return CloudUploadStatus(rawValue: rawCloudUploadStatus) ?? .notApplicable
        }
        set {
            rawCloudUploadStatus = newValue.rawValue
        }
    }
    
    init(amount: Double, foodType: String?, date: Date, externalID: String? = nil) {
        super.init(date: date)
        self.amount = amount
        self.foodType = foodType
        self.externalID = externalID ?? UUID().uuidString.lowercased()
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
    
    func markAsNotUploaded() {
        Realm.shared.safeWrite {
            self.cloudUploadStatus = .notUploaded
        }
    }
}

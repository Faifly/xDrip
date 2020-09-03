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
        super.init(date: date)
        self.amount = amount
        self.type = type
        self.externalID = externalID ?? UUID().uuidString.lowercased()
    }
    
    func update(amount: Double, date: Date) {
        Realm.shared.safeWrite {
            self.amount = amount
            self.updateDate(date)
            if self.cloudUploadStatus == .uploaded {
                 self.cloudUploadStatus = .modified
             }
        }
    }
}

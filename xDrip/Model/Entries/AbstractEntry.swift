//
//  AbstractEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

protocol AbstractEntryProtocol {
    var amount: Double { get }
    var date: Date? { get }
    var absorptionDuration: TimeInterval? { get set }
}

extension AbstractEntryProtocol {
    var absorptionDuration: TimeInterval? {
        get { return nil }
        set { absorptionDuration = newValue }
    }
}

class AbstractEntry: Object {
    @objc private(set) dynamic var date: Date?
    @objc private(set) dynamic var externalID: String = UUID().uuidString.lowercased()
    @objc private dynamic var rawCloudUploadStatus: Int = CloudUploadStatus.notApplicable.rawValue
    @objc private(set) dynamic var absorptionTime: TimeInterval = 0.0
    
    var absorptionDuration: TimeInterval? {
        get {
            return absorptionTime
        }
        set {
            Realm.shared.safeWrite {
                absorptionTime = newValue ?? 0.0
            }
        }
    }
    
    override class func primaryKey() -> String? {
        return "externalID"
    }

    var cloudUploadStatus: CloudUploadStatus {
        get {
            return CloudUploadStatus(rawValue: rawCloudUploadStatus) ?? .notApplicable
        }
        set {
            rawCloudUploadStatus = newValue.rawValue
        }
    }
    
    required init() {
        super.init()
    }
    
    init(date: Date, externalID: String? = nil) {
        super.init()
        self.date = date
        if let idString = externalID {
           self.externalID = idString
        }
    }
    
    func updateDate(_ date: Date) {
        Realm.shared.safeWrite {
            self.date = date
        }
    }

    var isValid: Bool {
      return cloudUploadStatus != .waitingForDeletion
    }
    
    func updateCloudUploadStatus(_ status: CloudUploadStatus) {
        Realm.shared.safeWrite {
            self.cloudUploadStatus = status
        }
    }
}

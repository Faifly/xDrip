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
}

protocol AbstractAbsorbableEntryProtocol: AbstractEntryProtocol {
    var absorptionDuration: TimeInterval { get }
}

class AbstractEntry: Object {
    @objc private(set) dynamic var date: Date?
    @objc private(set) dynamic var externalID: String = UUID().uuidString.lowercased()
    @objc private dynamic var rawCloudUploadStatus: Int = CloudUploadStatus.notUploaded.rawValue
    @objc private dynamic var rawDeviceMode: Int = UserDeviceMode.default.rawValue
    
    override class func primaryKey() -> String? {
        return "externalID"
    }

    var cloudUploadStatus: CloudUploadStatus {
        get {
            return CloudUploadStatus(rawValue: rawCloudUploadStatus) ?? .notUploaded
        }
        set {
            rawCloudUploadStatus = newValue.rawValue
        }
    }
    
    var deviceMode: UserDeviceMode {
        get {
            return UserDeviceMode(rawValue: rawDeviceMode) ?? .default
        }
        set {
            rawDeviceMode = newValue.rawValue
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

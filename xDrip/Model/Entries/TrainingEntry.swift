//
//  TrainingEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class TrainingEntry: AbstractEntry, TreatmentEntryProtocol {
    @objc private(set) dynamic var duration: TimeInterval = 0.0
    @objc private dynamic var rawIntensity: Int = TrainingIntensity.default.rawValue
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
    
    internal var amount: Double {
        return duration
    }
    
    var exerciseIntensity: Int? {
        get {
            return rawIntensity
        }
        set {
            rawIntensity = newValue ?? 1
        }
    }
    
    private(set) var intensity: TrainingIntensity {
        get {
            return TrainingIntensity(rawValue: rawIntensity) ?? .default
        }
        set {
            rawIntensity = newValue.rawValue
        }
    }
    
    required init() {
        super.init()
    }
    
    init(duration: TimeInterval, intensity: TrainingIntensity, date: Date, externalID: String? = nil) {
        super.init(date: date)
        self.duration = duration
        self.intensity = intensity
        self.externalID = externalID ?? UUID().uuidString.lowercased()
    }
    
    func update(duration: TimeInterval, intensity: TrainingIntensity, date: Date) {
        Realm.shared.safeWrite {
            self.duration = duration
            self.intensity = intensity
            self.updateDate(date)
            if self.cloudUploadStatus == .uploaded {
                self.cloudUploadStatus = .modified
            }
        }
        TrainingEntriesWorker.updatedTrainingEntry()
    }
    
    func markAsNotUploaded() {
        Realm.shared.safeWrite {
            self.cloudUploadStatus = .notUploaded
        }
    }
}

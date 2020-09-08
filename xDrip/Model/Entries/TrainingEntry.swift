//
//  TrainingEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class TrainingEntry: AbstractEntry {
    @objc private(set) dynamic var duration: TimeInterval = 0.0
    @objc private dynamic var rawIntensity: Int = TrainingIntensity.default.rawValue
    
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
    
    init(duration: TimeInterval, intensity: TrainingIntensity, date: Date) {
        super.init(date: date)
        self.duration = duration
        self.intensity = intensity
    }
    
    func update(duration: TimeInterval, intensity: TrainingIntensity, date: Date) {
        Realm.shared.safeWrite {
            self.duration = duration
            self.intensity = intensity
            self.updateDate(date)
        }
        TrainingEntriesWorker.updatedTrainingEntry()
    }
}

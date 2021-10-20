//
//  SettingsModeFollowerSessionWorker.swift
//  xDrip
//
//  Created by Dmitry on 21.10.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

protocol SettingsModeFollowerSessionWorkerLogic {
    func changeCurrentFollowerData()
}

final class SettingsModeFollowerSessionWorker: SettingsModeFollowerSessionWorkerLogic {
    func changeCurrentFollowerData() {
        guard let settings = User.current.settings.nightscoutSync else { return }
        
        if settings.currentFollowerBaseURL != settings.followerBaseURL {
            settings.updateCurrentFollowerBaseURL()
            
            GlucoseReading.deleteAllReadings(mode: .follower)
            LightGlucoseReading.deleteAllReadings(mode: .follower)
            CGMController.shared.notifyGlucoseChange()
            CarbEntriesWorker.deleteAllEntries(mode: .follower)
            InsulinEntriesWorker.deleteAllEntries(mode: .follower)
            TrainingEntriesWorker.deleteAllEntries(mode: .follower)
        }
    }
}

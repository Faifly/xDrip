//
//  PumpSyncSettings.swift
//  xDrip
//
//  Created by Artem Kalmykov on 05.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class PumpSyncSettings: Object {
    @objc private(set) dynamic var isEnabled: Bool = false
    @objc private(set) dynamic var nightscoutURL: String?
    @objc private(set) dynamic var pumpID: String?
    @objc private(set) dynamic var manufacturer: String?
    @objc private(set) dynamic var model: String?
    @objc private(set) dynamic var connectionDate: Date?
    
    func updateIsEnabled(_ enabled: Bool) {
        Realm.shared.safeWrite {
            self.isEnabled = enabled
        }
    }
    
    func updateNightscoutURL(_ url: String?) {
        Realm.shared.safeWrite {
            self.nightscoutURL = url
        }
    }
    
    func updatePumpID(_ pumpID: String?) {
        Realm.shared.safeWrite {
            self.pumpID = pumpID
        }
    }
    
    func updateManufacturer(_ manufacturer: String?) {
        Realm.shared.safeWrite {
            self.manufacturer = manufacturer
        }
    }
    
    func updateModel(_ model: String?) {
        Realm.shared.safeWrite {
            self.model = model
        }
    }
    
    func updateConnectionDate(_ date: Date?) {
        Realm.shared.safeWrite {
            self.connectionDate = date
        }
    }
}

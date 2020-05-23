//
//  CGMDeviceMetadata.swift
//  xDrip
//
//  Created by Artem Kalmykov on 02.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class CGMDeviceMetadata: Object {
    @objc private(set) dynamic var date: Date?
    @objc private(set) dynamic var value: String?
    @objc private dynamic var rawType: Int = -1
    
    private(set) var type: CGMDeviceMetadataType? {
        get {
            return CGMDeviceMetadataType(rawValue: rawType)
        }
        set {
            rawType = newValue?.rawValue ?? -1
        }
    }
    
    func resetDate() {
        Realm.shared.safeWrite {
            self.date = nil
        }
    }
    
    func update(withDate date: Date?, value: String?, type: CGMDeviceMetadataType) {
        Realm.shared.safeWrite {
            self.date = date
            self.value = value
            self.type = type
        }
    }
}

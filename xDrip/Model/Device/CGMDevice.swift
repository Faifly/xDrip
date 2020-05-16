//
//  CGMDevice.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class CGMDevice: Object {
    // MARK: Access
    
    private static let singleDeviceID: Int = 1
    @objc private dynamic var identifier: Int = CGMDevice.singleDeviceID
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    static var current: CGMDevice {
        let realm = Realm.shared
        if let device = realm.object(ofType: CGMDevice.self, forPrimaryKey: CGMDevice.singleDeviceID) {
            return device
        }
        
        let device = CGMDevice()
        realm.safeWrite {
            realm.add(device)
        }
        return device
    }
    
    // MARK: Setup
    
    @objc private(set) dynamic var isSetupInProgress = false
    
    func updateSetupProgress(_ inProgress: Bool) {
        Realm.shared.safeWrite {
            self.isSetupInProgress = inProgress
        }
    }
    
    // MARK: Device type
    
    @objc private dynamic var rawDeviceType: Int = -1
    
    private(set) var deviceType: CGMDeviceType? {
        get {
            return CGMDeviceType(rawValue: rawDeviceType)
        }
        set {
            rawDeviceType = newValue?.rawValue ?? -1
        }
    }
    
    func updateDeviceType(_ deviceType: CGMDeviceType?) {
        Realm.shared.safeWrite {
            self.deviceType = deviceType
        }
    }
    
    // MARK: Bluetooth ID
    
    @objc private(set) dynamic var bluetoothID: String?
    
    func updateBluetoothID(_ identifier: String?) {
        Realm.shared.safeWrite {
            self.bluetoothID = identifier
        }
    }
    
    // MARK: Metadata
    
    private let metatadaEntries = List<CGMDeviceMetadata>()
    
    func metadata(ofType type: CGMDeviceMetadataType) -> CGMDeviceMetadata? {
        return metatadaEntries.first(where: { $0.type == type })
    }
    
    func updateMetadata(ofType type: CGMDeviceMetadataType, value: String?, withDate date: Date = Date()) {
        let metadataEntry: CGMDeviceMetadata
        if let entry = metadata(ofType: type) {
            metadataEntry = entry
        } else {
            metadataEntry = CGMDeviceMetadata()
            Realm.shared.safeWrite {
                metadataEntry.addToRealm()
                metatadaEntries.append(metadataEntry)
            }
        }
        
        metadataEntry.update(withDate: date, value: value, type: type)
    }
    
    func requiresUpdate(for metadataType: CGMDeviceMetadataType) -> Bool {
        guard let entryDate = metadata(ofType: metadataType)?.date else { return true }
        return Date().timeIntervalSince1970 - entryDate.timeIntervalSince1970 > metadataType.updateInterval
    }
    
    var sensorStartDate: Date? {
        guard let sensorStartedString = CGMDevice.current.metadata(ofType: .sensorAge)?.value else { return nil }
        guard let sensorStarted = TimeInterval(sensorStartedString) else { return nil }
        return Date(timeIntervalSince1970: sensorStarted)
    }
}

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
    
    var isSetUp: Bool {
        return deviceType != nil && metadata(ofType: .serialNumber)?.value != nil
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
    
    func requireAllMetadataUpdate() {
        metatadaEntries.forEach { $0.resetDate() }
    }
    
    func resetAllMetadata() {
        Realm.shared.safeWrite {
            Realm.shared.delete(self.metatadaEntries)
            self.metatadaEntries.removeAll()
        }
    }
    
    // MARK: Sensor
    
    @objc private(set) dynamic var isSensorStarted: Bool = false
    
    func updateSensorIsStarted(_ isStarted: Bool) {
        Realm.shared.safeWrite {
            self.isSensorStarted = isStarted
        }
    }
    
    var sensorStartDate: Date? {
        get {
            guard let sensorStartedString = metadata(ofType: .sensorAge)?.value else { return nil }
            guard let sensorStarted = TimeInterval(sensorStartedString) else { return nil }
            return Date(timeIntervalSince1970: sensorStarted)
        }
        set {
            guard let newValue = newValue else {
                updateMetadata(ofType: .sensorAge, value: nil)
                return
            }
            updateMetadata(ofType: .sensorAge, value: "\(newValue.timeIntervalSince1970)")
        }
    }
    
    var isWarmingUp: Bool {
        guard !User.current.settings.skipWarmUp else { return false }
        guard isSensorStarted else { return false }
        guard let sensorStartDate = sensorStartDate else { return false }
        guard let deviceType = deviceType else { return false }
        return Date().timeIntervalSince1970 - sensorStartDate.timeIntervalSince1970 < deviceType.warmUpInterval
    }
    
    // MARK: Reset
    
    @objc private(set) dynamic var isResetScheduled: Bool = false
    
    func scheduleReset(_ isScheduled: Bool) {
        Realm.shared.safeWrite {
            self.isResetScheduled = isScheduled
        }
    }
}

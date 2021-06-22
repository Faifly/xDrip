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
    @objc private(set) dynamic var sensorStopScheduleDate: Date?
  
    func updateSensorIsStarted(_ isStarted: Bool, isOnlySensorAction: Bool = false) {
        Realm.shared.safeWrite {
            self.isSensorStarted = isStarted
        }
        
        if isStarted {
            NotificationCenter.default.postSettingsChangeNotification(setting: .sensorStarted)
            updateSensorStopScheduleDate(nil)
        } else {
            updateSensorStopScheduleDate(isOnlySensorAction ? Date() : nil)
        }
    }
    
    func updateSensorStopScheduleDate(_ date: Date?) {
        Realm.shared.safeWrite {
            self.sensorStopScheduleDate = date
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
            lastSensorStartDate = newValue
        }
    }
    
    var lastSensorStartDate: Date? {
        get {
            guard let sensorStartedString = metadata(ofType: .lastSensorAge)?.value else { return nil }
            guard let sensorStarted = TimeInterval(sensorStartedString) else { return nil }
            return Date(timeIntervalSince1970: sensorStarted)
        }
        set {
            guard let newValue = newValue else {
                updateMetadata(ofType: .lastSensorAge, value: nil)
                return
            }
            updateMetadata(ofType: .lastSensorAge, value: "\(newValue.timeIntervalSince1970)")
        }
    }
    
    func backupStartDate() {
        sensorStartDate = lastSensorStartDate
    }
    
    var transmitterStartDate: Date? {
        let transmitterData = CGMDevice.current.metadata(ofType: .transmitterTime)
        guard let ageString = transmitterData?.value,
              let age = Double(ageString),
              let date = transmitterData?.date else {
            return nil
        }
        return date - age
    }
    
    var transmitterVersionString: String? {
        return CGMDevice.current.metadata(ofType: .firmwareVersion)?.value
    }

    var isWarmingUp: Bool {
        guard !User.current.settings.skipWarmUp else { return false }
        guard isSensorStarted else { return false }
        guard let sensorStartDate = sensorStartDate else { return false }
        guard let deviceType = deviceType else { return false }
        return Date().timeIntervalSince1970 - sensorStartDate.timeIntervalSince1970 < deviceType.warmUpInterval
    }
    
    var sensorName: String? {
        guard let serial = metadata(ofType: .serialNumber)?.value else { return nil }
        guard let deviceType = deviceType else { return nil }
        return deviceType.prefix + serial.suffix(2)
    }
    
    // MARK: Reset
    
    @objc private(set) dynamic var isResetScheduled: Bool = false
    
    func scheduleReset(_ isScheduled: Bool) {
        Realm.shared.safeWrite {
            self.isResetScheduled = isScheduled
        }
    }
    
    var withCalibrationResponse: Bool {
        if let deviceType = deviceType,
           deviceType == .dexcomG6,
           let firstVersionCharacter = CGMDevice.current.transmitterVersionString?.first,
           let transmitterVersion = DexcomG6FirmwareVersion(rawValue: firstVersionCharacter),
           transmitterVersion == .second {
            return true
        } else {
            return false
        }
    }
}

//
//  User.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift
import AKRealmUtils

final class User: Object {
    // MARK: Access
    
    private static let singleUserID: Int = 1
    @objc private dynamic var id: Int = User.singleUserID
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static var current: User {
        let realm = Realm.shared
        if let user = realm.object(ofType: User.self, forPrimaryKey: User.singleUserID) {
            return user
        }
        
        let user = User()
        realm.safeWrite {
            realm.add(user)
        }
        return user
    }
    
    // MARK: Device mode
    
    @objc private dynamic var rawDeviceMode: Int = DeviceMode.default.rawValue
    
    private(set) var deviceMode: DeviceMode {
        get {
            return DeviceMode(rawValue: rawDeviceMode) ?? .default
        }
        set {
            rawDeviceMode = newValue.rawValue
        }
    }
    
    func updateDeviceMode(_ deviceMode: DeviceMode) {
        Realm.shared.safeWrite {
            self.deviceMode = deviceMode
        }
    }
    
    // MARK: Injection type
    
    @objc private dynamic var rawInjectionType: Int = InjectionType.default.rawValue
    
    private(set) var injectionType: InjectionType {
        get {
            return InjectionType(rawValue: rawInjectionType) ?? .default
        }
        set {
            rawInjectionType = newValue.rawValue
        }
    }
    
    func updateInjectionType(_ injectionType: InjectionType) {
        Realm.shared.safeWrite {
            self.injectionType = injectionType
        }
    }
    
    // MARK: Unit
    
    @objc private dynamic var rawUnit: Int = GlucoseUnit.default.rawValue
    
    private(set) var unit: GlucoseUnit {
        get {
            return GlucoseUnit(rawValue: rawUnit) ?? .default
        }
        set {
            rawUnit = newValue.rawValue
        }
    }
    
    func updateUnit(_ unit: GlucoseUnit) {
        Realm.shared.safeWrite {
            self.unit = unit
        }
    }
    
    // MARK: Warning levels
    
    private let glucoseWarningLevels = List<GlucoseWarningLevelSetting>()
    
    func warningLevelValue(for level: GlucoseWarningLevel) -> Double {
        return glucoseWarningLevels.first(where: { $0.warningLevel == level })?.value ?? level.defaultValue
    }
    
    func configureWarningLevel(_ level: GlucoseWarningLevel, value: Double) {
        let realm = Realm.shared
        realm.safeWrite {
            if let obj = glucoseWarningLevels.first(where: { $0.warningLevel == level }) {
                obj.updateValue(value)
            } else {
                let obj = GlucoseWarningLevelSetting(level: level, value: value)
                glucoseWarningLevels.append(obj)
                realm.add(obj)
            }
        }
    }
    
    // MARK: Glucose data
    
    let glucoseData = List<GlucoseData>()
    
    @discardableResult func addGlucoseDataEntry(_ value: Double, date: Date = Date()) -> GlucoseData {
        let entry = GlucoseData(value: value, date: date)
        Realm.shared.safeWrite {
            glucoseData.append(entry)
        }
        return entry
    }
    
    // MARK: Settings
    
    private static let defaultCarbsAbsorptionLevel: TimeInterval = 1200.0 // 20 minutes
    private static let defaultInsulinActionTime: TimeInterval = 21600.0 // 6 hours
    
    @objc private(set) dynamic var isInsulinChartEnabled: Bool = true
    @objc private(set) dynamic var isCarbohydratesChartEnabled: Bool = true
    @objc private(set) dynamic var carbsAbsorptionRate: TimeInterval = User.defaultCarbsAbsorptionLevel
    @objc private(set) dynamic var insulinActionTime: TimeInterval = User.defaultInsulinActionTime
    
    func updateInsulinChartEnabled(_ enabled: Bool) {
        Realm.shared.safeWrite {
            self.isInsulinChartEnabled = enabled
        }
    }
    
    func updateCarbohydratesChartEnabled(_ enabled: Bool) {
        Realm.shared.safeWrite {
            self.isCarbohydratesChartEnabled = enabled
        }
    }
    
    func updateCarbsAbsorptionRate(_ rate: TimeInterval) {
        Realm.shared.safeWrite {
            self.carbsAbsorptionRate = rate
        }
    }
    
    func updateInsulinActionTime(_ time: TimeInterval) {
        Realm.shared.safeWrite {
            self.insulinActionTime = time
        }
    }
    
    // MARK: Initial setup
    @objc private(set) dynamic var isInitialSetupDone = false
    
    func setIsInitialSetupDone(_ done: Bool) {
        Realm.shared.safeWrite {
            self.isInitialSetupDone = done
        }
    }
}

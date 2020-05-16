//
//  Settings.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class Settings: Object {
    @objc private(set) dynamic var chart: ChartSettings?
    @objc private(set) dynamic var alert: AlertSettings?
    @objc private(set) dynamic var nightscoutSync: NightscoutSyncSettings?
    
    required init() {
        super.init()
        chart = ChartSettings()
        alert = AlertSettings()
        nightscoutSync = NightscoutSyncSettings()
    }
    
    // MARK: Device mode
    
    @objc private dynamic var rawDeviceMode: Int = UserDeviceMode.default.rawValue
    
    private(set) var deviceMode: UserDeviceMode {
        get {
            return UserDeviceMode(rawValue: rawDeviceMode) ?? .default
        }
        set {
            rawDeviceMode = newValue.rawValue
        }
    }
    
    func updateDeviceMode(_ deviceMode: UserDeviceMode) {
        Realm.shared.safeWrite {
            self.deviceMode = deviceMode
        }
    }
    
    // MARK: Injection type
    
    @objc private dynamic var rawInjectionType: Int = UserInjectionType.default.rawValue
    
    private(set) var injectionType: UserInjectionType {
        get {
            return UserInjectionType(rawValue: rawInjectionType) ?? .default
        }
        set {
            rawInjectionType = newValue.rawValue
        }
    }
    
    func updateInjectionType(_ injectionType: UserInjectionType) {
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
    
    private static let defaultCarbsAbsorptionLevel: TimeInterval = 1200.0 // 20 minutes
    private static let defaultInsulinActionTime: TimeInterval = 21600.0 // 6 hours
    
    @objc private(set) dynamic var carbsAbsorptionRate: TimeInterval = Settings.defaultCarbsAbsorptionLevel
    @objc private(set) dynamic var insulinActionTime: TimeInterval = Settings.defaultInsulinActionTime
    
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
    
    // MARK: Basal rates
    
    let basalRates = List<BasalRate>()
    
    @discardableResult func addBasalRate(startTime: TimeInterval, units: Float) -> BasalRate {
        let rate = BasalRate(startTime: startTime, units: units)
        Realm.shared.safeWrite {
            basalRates.append(rate)
        }
        return rate
    }
}

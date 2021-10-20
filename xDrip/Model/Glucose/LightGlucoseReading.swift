//
//  LightGlucoseReading.swift
//  xDrip
//
//  Created by Dmitry on 19.02.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation
import RealmSwift
import AKUtils

final class LightGlucoseReading: Object, BaseGlucoseReading {
    @objc private(set) dynamic var date: Date?
    @objc private(set) dynamic var calculatedValue: Double = 0.0
    @objc private(set) dynamic var filteredCalculatedValue: Double = 0.0
    @objc private(set) dynamic var calculatedValueSlope: Double = 0.0
    @objc private dynamic var rawDeviceMode: Int = UserDeviceMode.default.rawValue
    
    var deviceMode: UserDeviceMode {
        get {
            return UserDeviceMode(rawValue: rawDeviceMode) ?? .default
        }
        set {
            rawDeviceMode = newValue.rawValue
        }
    }
    
    required init() {
        super.init()
    }
    
    init(reading: GlucoseReading) {
        super.init()
        date = reading.date
        calculatedValue = reading.calculatedValue
        filteredCalculatedValue = reading.filteredCalculatedValue
        calculatedValueSlope = reading.calculatedValueSlope
        deviceMode = reading.deviceMode
    }
    
    func setFilteredCalculatedValue(_ value: Double) {
        self.filteredCalculatedValue = value
    }
    
    func setDate(_ date: Date) {
        self.date = date
    }
    
    static var allReadings: Results<LightGlucoseReading> {
        return Realm.shared.objects(LightGlucoseReading.self).sorted(by: [.dateDescending])
    }
    
    static var allMaster: Results<LightGlucoseReading> {
        return allReadings
            .filter(.deviceMode(mode: .main))
    }
    
    private static var allFollower: Results<LightGlucoseReading> {
        return allReadings
            .filter(.deviceMode(mode: .follower))
    }
    
    static var allForCurrentMode: Results<LightGlucoseReading> {
        clearOldReadings()
        return User.current.settings.deviceMode == .follower ? allFollower : allMaster
    }
    
    static func readingsForInterval(_ interval: DateInterval) -> Results<LightGlucoseReading> {
        return allForCurrentMode.filter(
            NSCompoundPredicate(type: .and, subpredicates: [
                .laterThanOrEqual(date: interval.start),
                .earlierThanOrEqual(date: interval.end)
            ]))
    }
    
    private static func clearOldReadings() {
        let oldReadings = allReadings
            .filter(.earlierThan(date: Date().addingTimeInterval(-(Constants.observablePeriod))))
        let realm = Realm.shared
        realm.safeWrite {
            realm.delete(oldReadings)
        }
    }
    
    static func deleteAllReadings(mode: UserDeviceMode) {
        let objects = Realm.shared.objects(LightGlucoseReading.self).filter(.deviceMode(mode: mode))
        let realm = Realm.shared
        realm.safeWrite {
            realm.delete(objects)
        }
    }
}

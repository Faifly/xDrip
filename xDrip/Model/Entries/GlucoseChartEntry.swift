//
//  GlucoseChartEntry.swift
//  xDrip
//
//  Created by Ivan Skoryk on 19.01.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

final class GlucoseChartEntry: Object {
    @objc private(set) dynamic var externalID: String?
    @objc private(set) dynamic var rawValue: Double = 0.0
    @objc private(set) dynamic var date: Date?
    @objc private(set) dynamic var calculatedValue: Double = 0.0
    @objc private(set) dynamic var filteredCalculatedValue: Double = 0.0
    @objc private(set) dynamic var calculatedValueSlope: Double = 0.0
    @objc private dynamic var rawDeviceMode: Int = UserDeviceMode.default.rawValue
    
    override class func primaryKey() -> String? {
        return "externalID"
    }
    
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
        externalID = reading.externalID
        date = reading.date
        calculatedValue = reading.calculatedValue
        filteredCalculatedValue = reading.filteredCalculatedValue
        calculatedValueSlope = reading.calculatedValueSlope
        deviceMode = reading.deviceMode
    }
    
    private static var emptyReadingsArray = Realm.shared.objects(GlucoseChartEntry.self).filter(NSPredicate(value: false))
    
    static var allMaster: Results<GlucoseChartEntry> {
        return Realm.sharedCharts.objects(GlucoseChartEntry.self)
                .filter("rawDeviceMode = \(UserDeviceMode.main.rawValue)")
    }
    
    static var allFollower: Results<GlucoseChartEntry> {
        return Realm.sharedCharts.objects(GlucoseChartEntry.self)
                .filter("rawDeviceMode = \(UserDeviceMode.follower.rawValue)")
    }
    
    static var allForCurrentMode: Results<GlucoseChartEntry> {
        return User.current.settings.deviceMode == .follower ? allFollower : allMaster
    }
    
    static var allMasterForCurrentSensor: Results<GlucoseChartEntry> {
        guard CGMDevice.current.isSensorStarted else { return emptyReadingsArray }
        guard let sensorStartDate = CGMDevice.current.sensorStartDate else { return emptyReadingsArray }
        return allMaster.filter("date > %@", sensorStartDate)
    }
    
    static func readingsForInterval(_ interval: DateInterval) -> Results<GlucoseChartEntry> {
        return allForCurrentMode.filter("date >= %@ AND date <= %@", interval.start, interval.end)
    }
    
    static func lastReadings(_ amount: Int, for mode: UserDeviceMode) -> Results<GlucoseChartEntry> {
        return last(for: mode, amount: amount, filter: "calculatedValue != 0.0 AND rawValue != 0.0")
    }
    
    static func latestByCount(_ amount: Int, for mode: UserDeviceMode) -> Results<GlucoseChartEntry> {
        return last(for: mode, amount: amount, filter: "rawValue != 0.0")
    }
    
    static func last(for mode: UserDeviceMode, amount: Int, filter: String) -> Results<GlucoseChartEntry> {
        guard amount > 0 else { return emptyReadingsArray }
        
        let allReadings = mode == .main ? allMasterForCurrentSensor : allFollower
        
        let start = allReadings.first?.date ?? Date()
        let interval = TimeInterval(amount) * TimeInterval(minutes: 5.5)
        let endDate = start.addingTimeInterval(-interval)
        
        return allReadings.filter(filter + " AND date > %@", endDate)
    }
}

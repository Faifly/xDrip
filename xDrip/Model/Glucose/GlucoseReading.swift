//
//  GlucoseReading.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift
import AKUtils

// swiftlint:disable identifier_name
// swiftlint:disable large_tuple
// swiftlint:disable type_body_length
final class GlucoseReading: Object {
    private static let ageAdjustmentTime = TimeInterval.secondsPerDay * 1.9
    private static let ageAdjustmentFactor = 0.45
    
    @objc private(set) dynamic var filteredValue: Double = 0.0
    @objc private(set) dynamic var rawValue: Double = 0.0
    @objc private(set) dynamic var date: Date?
    @objc private(set) dynamic var calculatedValue: Double = 0.0
    @objc private(set) dynamic var filteredCalculatedValue: Double = 0.0
    @objc private(set) dynamic var isCalibrated: Bool = false
    @objc private(set) dynamic var a: Double = 0.0
    @objc private(set) dynamic var b: Double = 0.0
    @objc private(set) dynamic var c: Double = 0.0
    @objc private(set) dynamic var ra: Double = 0.0
    @objc private(set) dynamic var rb: Double = 0.0
    @objc private(set) dynamic var rc: Double = 0.0
    @objc private(set) dynamic var ageAdjustedRawValue: Double = 0.0
    @objc private(set) dynamic var calibration: Calibration?
    @objc private(set) dynamic var hideSlope: Bool = false
    @objc private(set) dynamic var calculatedValueSlope: Double = 0.0
    @objc private(set) dynamic var timeSinceSensorStarted: TimeInterval = 0.0
    @objc private(set) dynamic var externalID: String?
    @objc private dynamic var rawDeviceMode: Int = UserDeviceMode.default.rawValue
    @objc private dynamic var rawCloudUploadStatus: Int = CloudUploadStatus.notApplicable.rawValue
    
    override class func primaryKey() -> String? {
        return "externalID"
    }
    
    var cloudUploadStatus: CloudUploadStatus {
        get {
            return CloudUploadStatus(rawValue: rawCloudUploadStatus) ?? .notApplicable
        }
        set {
            rawCloudUploadStatus = newValue.rawValue
        }
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
    
    static var allMaster: [GlucoseReading] {
        return Array(
            Realm.shared.objects(GlucoseReading.self)
            .filter("rawDeviceMode = \(UserDeviceMode.main.rawValue)")
            .sorted(byKeyPath: "date", ascending: false)
        )
    }
    
    static var allFollower: [GlucoseReading] {
        return Array(
            Realm.shared.objects(GlucoseReading.self)
            .filter("rawDeviceMode = \(UserDeviceMode.follower.rawValue)")
            .sorted(byKeyPath: "date", ascending: false)
        )
    }
    
    static var allMasterForCurrentSensor: [GlucoseReading] {
        guard CGMDevice.current.isSensorStarted else { return [] }
        guard let sensorStartDate = CGMDevice.current.sensorStartDate else { return [] }
        return allMaster.filter { $0.date >? sensorStartDate }
    }
    
    static func lastMasterReadings(_ amount: Int) -> [GlucoseReading] {
        return lastMaster(amount: amount, filter: { $0.calculatedValue !~ 0 && $0.rawValue !~ 0 })
    }
    
    static func latestMasterByCount(_ amount: Int) -> [GlucoseReading] {
        return lastMaster(amount: amount, filter: { $0.rawValue !~ 0 })
    }
    
    static func lastMaster(amount: Int, filter: (GlucoseReading) -> Bool) -> [GlucoseReading] {
        guard amount > 0 else { return [] }
        
        let allReadings = allMasterForCurrentSensor.filter(filter)
        if allReadings.count > amount {
            return Array(allReadings[0..<amount])
        }
        
        return Array(allReadings)
    }
    
    @discardableResult static func create(filtered: Double,
                                          unfiltered: Double,
                                          date: Date = Date()) -> GlucoseReading? {
        LogController.log(message: "[Glucose] Trying to create reading...", type: .debug)
        guard let sensorStarted = CGMDevice.current.sensorStartDate, CGMDevice.current.isSensorStarted else {
            LogController.log(message: "[Glucose] Can't create reading, sensor not started", type: .error)
            return nil
        }
        
        let reading = GlucoseReading()
        reading.externalID = UUID().uuidString
        reading.calibration = Calibration.calibration(for: date)
        reading.rawValue = unfiltered
        reading.filteredValue = filtered
        reading.date = date
        reading.timeSinceSensorStarted = date.timeIntervalSince1970 - sensorStarted.timeIntervalSince1970
        reading.calculateAgeAdjustedRawValue()
        reading.findSlope()
        
        if let settings = User.current.settings.nightscoutSync, settings.isEnabled {
            reading.cloudUploadStatus = .notUploaded
        }
        
        Realm.shared.safeWrite {
            Realm.shared.add(reading)
        }
        
        reading.findNewCurve()
        reading.findNewRawCurve()
        
        Calibration.adjustRecentReadings(1)
        
        LogController.log(
            message: "[Glucose] Created reading with calculated value: %@",
            type: .debug,
            "\(reading.calculatedValue)"
        )
        
        if Calibration.allForCurrentSensor.isEmpty && GlucoseReading.allMasterForCurrentSensor.count >= 2 {
            CalibrationController.shared.requestInitialCalibration()
        }
        
        NightscoutService.shared.scanForNotUploadedEntries()
        
        return reading
    }
    
    static func reading(for date: Date) -> GlucoseReading? {
        let allowedOffset = TimeInterval.secondsPerMinute * 15.0
        let minOffset = date - allowedOffset
        let maxOffset = date + allowedOffset
        let matching = allMaster.filter { $0.date >? minOffset && $0.date <? maxOffset }
        let offsets = matching.map {
            abs(($0.date?.timeIntervalSince1970 ?? .greatestFiniteMagnitude) - date.timeIntervalSince1970)
        }
        
        var min = TimeInterval.greatestFiniteMagnitude
        var minIndex: Int?
        for (i, offset) in offsets.enumerated() where offset < min {
            min = offset
            minIndex = i
        }
        
        if let minIndex = minIndex {
            return matching[minIndex]
        }
        
        return nil
    }
    
    static func estimatedRawGlucoseLevel(date: Date) -> Double {
        guard let last = lastMasterReadings(1).first else { return 160.0 }
        return last.ra * pow(date.timeIntervalSince1970, 2) + last.rb * date.timeIntervalSince1970 + last.rc
    }
    
    static func markEntryAsUploaded(externalID: String) {
        guard let entry = allMaster.first(where: { $0.externalID == externalID }) else {
            return
        }
        Realm.shared.safeWrite {
            entry.cloudUploadStatus = .uploaded
        }
    }
    
    static func parseFollowerEntries(_ rawEntries: [CGlucoseReading]) {
        let readings = rawEntries.map { createReading(from: $0) }
        let realm = Realm.shared
        realm.safeWrite {
            realm.add(readings, update: .all)
        }
    }
    
    static func createReading(from rawEntry: CGlucoseReading) -> GlucoseReading {
        let entry = GlucoseReading()
        entry.calculatedValue = Double(rawEntry.sgv ?? 0)
        entry.filteredCalculatedValue = entry.calculatedValue
        entry.date = Date(timeIntervalSince1970: TimeInterval(rawEntry.date ?? 0) / 1000.0)
        entry.deviceMode = .follower
        entry.externalID = rawEntry.identifier
        return entry
    }
    
    func updateCalculatedValue(_ value: Double) {
        Realm.shared.safeWrite {
            self.calculatedValue = value
            if self.cloudUploadStatus == .uploaded {
                self.cloudUploadStatus = .modified
            }
        }
    }
    
    func updateFilteredCalculatedValue(_ value: Double) {
        Realm.shared.safeWrite {
            self.filteredCalculatedValue = value
        }
    }
    
    func updateIsCalibrated(_ isCalibrated: Bool) {
        Realm.shared.safeWrite {
            self.isCalibrated = isCalibrated
        }
    }
    
    func findNewCurve() {
        let curve = findCurve(valueKey: "calculatedValue", bKey: "b")
        
        Realm.shared.safeWrite {
            self.a = curve.a
            self.b = curve.b
            self.c = curve.c
        }
    }
    
    func findNewRawCurve() {
        let curve = findCurve(valueKey: "ageAdjustedRawValue", bKey: "rb")
        
        Realm.shared.safeWrite {
            self.ra = curve.a
            self.rb = curve.b
            self.rc = curve.c
        }
    }
    
    func updateCalibration(_ calibration: Calibration?) {
        Realm.shared.safeWrite {
            self.calibration = calibration
        }
    }
    
    func calculateSlope(lastReading: GlucoseReading) -> Double {
        guard let selfDate = date?.timeIntervalSince1970 else { return 0.0 }
        guard let lastDate = lastReading.date?.timeIntervalSince1970 else { return 0.0 }
        
        if selfDate ~~ lastDate || calculatedValue ~ lastReading.calculatedValue {
            return 0.0
        }
        
        return (lastReading.calculatedValue - calculatedValue) / (lastDate - selfDate)
    }
    
    func findSlope() {
        let last2Readings = GlucoseReading.lastMasterReadings(2)
        
        Realm.shared.safeWrite {
            if last2Readings.count == 2 {
                calculatedValueSlope = calculateSlope(lastReading: last2Readings[1])
            } else {
                calculatedValueSlope = 0.0
            }
        }
    }
    
    func calculateAgeAdjustedRawValue() {
        let adjustFor = GlucoseReading.ageAdjustmentTime - timeSinceSensorStarted
        Realm.shared.safeWrite {
            if adjustFor > 0 {
                let factor = GlucoseReading.ageAdjustmentFactor
                let time = GlucoseReading.ageAdjustmentTime
                ageAdjustedRawValue = ((factor * (adjustFor / time)) * rawValue) + rawValue
            } else {
                ageAdjustedRawValue = rawValue
            }
        }
    }
    
    private func findCurve(valueKey: String, bKey: String) -> (a: Double, b: Double, c: Double) {
        let last3 = GlucoseReading.lastMasterReadings(3)
        
        let a: Double
        let b: Double
        let c: Double
        
        if last3.count == 3 {
            let y3 = last3[0].value(forKey: valueKey) as? Double ?? 1.0
            let x3 = last3[0].date?.timeIntervalSince1970 ?? 1.0
            let y2 = last3[1].value(forKey: valueKey) as? Double ?? 1.0
            let x2 = last3[1].date?.timeIntervalSince1970 ?? 1.0
            let y1 = last3[2].value(forKey: valueKey) as? Double ?? 1.0
            let x1 = last3[2].date?.timeIntervalSince1970 ?? 1.0
            
            a = y1 / ((x1 - x2) * (x1 - x3)) + y2 / ((x2 - x1) * (x2 - x3)) + y3 / ((x3 - x1) * (x3 - x2))
            b = -y1 * (x2 + x3) / ((x1 - x2) * (x1 - x3))
                - y2 * (x1 + x3) / ((x2 - x1) * (x2 - x3))
                - y3 * (x1 + x2) / ((x3 - x1) * (x3 - x2))
            c = y1 * x2 * x3 / ((x1 - x2) * (x1 - x3))
                + y2 * x1 * x3 / ((x2 - x1) * (x2 - x3))
                + y3 * x1 * x2 / ((x3 - x1) * (x3 - x2))
        } else if last3.count == 2 {
            let y2 = last3[0].value(forKey: valueKey) as? Double ?? 1.0
            let x2 = last3[0].date?.timeIntervalSince1970 ?? 1.0
            let y1 = last3[1].value(forKey: valueKey) as? Double ?? 1.0
            let x1 = last3[1].date?.timeIntervalSince1970 ?? 1.0
            let lastB = last3[0].value(forKey: bKey) as? Double ?? 0.0
            
            if y1 ~ y2 {
                b = 0.0
            } else {
                b = (y2 - y1) / (x2 - x1)
            }
            a = 0.0
            c = -1.0 * ((lastB * x1) - y1)
        } else {
            a = 0.0
            b = 0.0
            c = value(forKey: valueKey) as? Double ?? 0.0
        }
        
        return (a, b, c)
    }
    
    func updateCalculatedValueToWithinMinMax() {
        Realm.shared.safeWrite {
            if calculatedValue < 10.0 {
                calculatedValue = -1.0
                hideSlope = true
            } else {
                calculatedValue = min(400.0, max(39.0, calculatedValue))
                hideSlope = false
            }
        }
    }
    
    func activeSlope() -> Double {
        return 2 * a * Date().timeIntervalSince1970 + b
    }
}

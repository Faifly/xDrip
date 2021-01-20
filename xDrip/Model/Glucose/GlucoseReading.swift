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
// swiftlint:disable file_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

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
    @objc private(set) dynamic var noise: String = "1"
    @objc private(set) dynamic var rssi: Double = 0.0
    @objc private(set) dynamic var displayGlucose: Double = 0.0
    @objc private(set) dynamic var displaySlope: Double = 0.0
    @objc private(set) dynamic var displayDeltaName: String?
    @objc private dynamic var rawDeviceMode: Int = UserDeviceMode.default.rawValue
    @objc private dynamic var rawCloudUploadStatus: Int = CloudUploadStatus.notApplicable.rawValue
    @objc private(set) dynamic var sourceInfo: String?
    
    override class func primaryKey() -> String? {
        return "externalID"
    }
    
    override class func indexedProperties() -> [String] {
        return ["date"]
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
    
    private static var emptyReadingsArray = Realm.shared.objects(GlucoseReading.self).filter(NSPredicate(value: false))
    
    static var allMaster: Results<GlucoseReading> {
        return Realm.shared.objects(GlucoseReading.self)
                .filter("rawDeviceMode = \(UserDeviceMode.main.rawValue)")
                .sorted(byKeyPath: "date", ascending: false)
    }
    
    static var allFollower: Results<GlucoseReading> {
        return Realm.shared.objects(GlucoseReading.self)
                .filter("rawDeviceMode = \(UserDeviceMode.follower.rawValue)")
                .sorted(byKeyPath: "date", ascending: false)
    }
    
    static var allForCurrentMode: Results<GlucoseReading> {
        return User.current.settings.deviceMode == .follower ? allFollower : allMaster
    }
    
    static var allMasterForCurrentSensor: Results<GlucoseReading> {
        guard CGMDevice.current.isSensorStarted else { return emptyReadingsArray }
        guard let sensorStartDate = CGMDevice.current.sensorStartDate else { return emptyReadingsArray }
        return allMaster.filter("date > %@", sensorStartDate)
    }
    
    static func lastReadings(_ amount: Int, for mode: UserDeviceMode) -> Results<GlucoseReading> {
        return last(for: mode, amount: amount, filter: "calculatedValue != 0.0 AND rawValue != 0.0")
    }
    
    static func latestByCount(_ amount: Int, for mode: UserDeviceMode) -> Results<GlucoseReading> {
        return last(for: mode, amount: amount, filter: "rawValue != 0.0")
    }
    
    static func last(for mode: UserDeviceMode, amount: Int, filter: String) -> Results<GlucoseReading> {
        guard amount > 0 else { return emptyReadingsArray }
        
        let allReadings = mode == .main ? allMasterForCurrentSensor : allFollower
        
        let start = allReadings.first?.date ?? Date()
        let interval = TimeInterval(amount) * TimeInterval(minutes: 5.5)
        let endDate = start.addingTimeInterval(-interval)
        
        return allReadings.filter(filter + " AND date > %@", endDate)
    }
    
    static var masterForCurrentSensorInLast30Minutes: Results<GlucoseReading> {
        return allMasterForCurrentSensor.filter("date > %@", Date().addingTimeInterval(-(.secondsPerHour / 2)))
    }
    
    @discardableResult static func create(filtered: Double,
                                          unfiltered: Double,
                                          rssi: Double,
                                          date: Date = Date(),
                                          requireCalibration: Bool = true) -> GlucoseReading? {
        LogController.log(message: "[Glucose] Trying to create reading...", type: .debug)
        guard let sensorStarted = CGMDevice.current.sensorStartDate, CGMDevice.current.isSensorStarted else {
            LogController.log(message: "[Glucose] Can't create reading, sensor not started", type: .error)
            return nil
        }
        guard filtered > .ulpOfOne && unfiltered > .ulpOfOne else {
            LogController.log(message: "[Glucose] Can't create reading, value is below zero", type: .error)
            return nil
        }
        
        let reading = GlucoseReading()
        reading.externalID = UUID().uuidString
        reading.calibration = Calibration.calibration(for: date)
        reading.rawValue = unfiltered / 1000.0
        reading.filteredValue = filtered / 1000.0
        reading.date = date
        reading.timeSinceSensorStarted = date.timeIntervalSince1970 - sensorStarted.timeIntervalSince1970
        reading.rssi = rssi
        reading.calculateAgeAdjustedRawValue()
        reading.findSlope()
        reading.sourceInfo = CGMDevice.current.deviceType?.title
        
        if let settings = User.current.settings.nightscoutSync, settings.isEnabled {
            reading.cloudUploadStatus = .notUploaded
        }
        
        Realm.shared.safeWrite {
            Realm.shared.add(reading)
        }
        
        reading.findNewCurve()
        reading.findNewRawCurve()
        
        Calibration.adjustRecentReadings(1)
        reading.calculateNoise()
        reading.injectDisplayGlucose()
        
        LogController.log(
            message: "[Glucose] Created reading with calculated value: %@",
            type: .debug,
            "\(reading.calculatedValue)"
        )
        
        checkForCalibrationRequest(requireCalibration)
        
        NightscoutService.shared.scanForNotUploadedEntries()
        
        let chartEntry = GlucoseChartEntry(reading: reading)
        Realm.sharedCharts.safeWrite {
            Realm.sharedCharts.add(chartEntry, update: .modified)
        }
        
        return reading
    }
        
    @discardableResult static func createFromG6(calculatedValue: Double,
                                                date: Date,
                                                forBackfill: Bool = false,
                                                requireCalibration: Bool = true) -> GlucoseReading? {
        LogController.log(message: "[Glucose] Trying to create reading...", type: .debug)
        guard CGMDevice.current.isSensorStarted else {
            LogController.log(message: "[Glucose] Can't createFromG6 reading, sensor not started", type: .error)
            return nil
        }
        
        guard calculatedValue > .ulpOfOne else {
            LogController.log(message: "[Glucose] Can't createFromG6 reading, calculatedValue is below zero",
                              type: .error)
            return nil
        }
        
        let reading = GlucoseReading()
        reading.externalID = UUID().uuidString
        reading.calculatedValue = calculatedValue
        reading.filteredCalculatedValue = calculatedValue
        reading.rawValue = Constants.specialG5RawValuePlaceholder
        reading.date = date
        reading.sourceInfo = CGMDevice.current.deviceType?.title ?? "" + (forBackfill ? "Backfill" : "")
        
        if let settings = User.current.settings.nightscoutSync, settings.isEnabled,
           !forBackfill {
            reading.cloudUploadStatus = .notUploaded
        }
        
        Realm.shared.safeWrite {
            Realm.shared.add(reading)
        }
        
        LogController.log(
            message: "[Glucose] Created FromG6 reading with calculated value: %@",
            type: .debug,
            "\(reading.calculatedValue)"
        )
        
        if !forBackfill {
            checkForCalibrationRequest(requireCalibration)
            NightscoutService.shared.scanForNotUploadedEntries()
        }
        
        let chartEntry = GlucoseChartEntry(reading: reading)
        Realm.sharedCharts.safeWrite {
            Realm.sharedCharts.add(chartEntry, update: .modified)
        }
        
        return reading
    }
    
    private static func checkForCalibrationRequest(_ requireCalibration: Bool) {
        if Calibration.allForCurrentSensor.isEmpty
            && GlucoseReading.allMasterForCurrentSensor.count >= 2
            && requireCalibration {
            CalibrationController.shared.requestInitialCalibration()
        } else if CalibrationController.shared.canShowNextRegularCalibrationRequest() &&
                    CalibrationController.shared.isOptimalConditionToCalibrate() &&
                    masterForCurrentSensorInLast30Minutes.count >= 2 {
            CalibrationController.shared.requestRegularCalibration()
        }
    }
    
    static func reading(for date: Date, precisionInMinutes: Int = 15, lockToSensor: Bool = false) -> GlucoseReading? {
        let allowedOffset = TimeInterval.secondsPerMinute * Double(precisionInMinutes)
        let minOffset = date - allowedOffset
        let maxOffset = date + allowedOffset
        let matching = allMaster.filter("date > %@ AND date < %@", minOffset, maxOffset)
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
        guard let last = lastReadings(1, for: .main).first else { return 160.0 }
        return last.ra * pow(date.timeIntervalSince1970, 2) + last.rb * date.timeIntervalSince1970 + last.rc
    }
    
    static func markEntryAsUploaded(externalID: String) {
        guard let entry = allMaster.filter("externalID == \(externalID)").first else {
            return
        }
        Realm.shared.safeWrite {
            entry.cloudUploadStatus = .uploaded
        }
    }
    
    func updateCloudUploadStatus(_ status: CloudUploadStatus) {
         Realm.shared.safeWrite {
             self.cloudUploadStatus = status
         }
     }
    
    static func parseFollowerEntries(_ rawEntries: [CGlucoseReading]) -> [GlucoseReading] {
        let readings = rawEntries.compactMap { createReading(from: $0) }
        let realm = Realm.shared
        realm.safeWrite {
            realm.add(readings, update: .all)
        }
        
        let chartEntries = readings.compactMap { GlucoseChartEntry(reading: $0) }
        Realm.sharedCharts.safeWrite {
            Realm.sharedCharts.add(chartEntries, update: .modified)
        }
        
        return readings
    }
    
    static func createReading(from rawEntry: CGlucoseReading) -> GlucoseReading? {
        guard rawEntry.type == "sgv" else { return nil }
        let entry = GlucoseReading()
        entry.calculatedValue = Double(rawEntry.sgv ?? 0)
        entry.filteredCalculatedValue = entry.calculatedValue
        entry.date = Date(timeIntervalSince1970: TimeInterval(rawEntry.date ?? 0) / 1000.0)
        entry.deviceMode = .follower
        entry.externalID = rawEntry.identifier
        entry.sourceInfo = "Nightscout Follower"
        return entry
    }
    
    static func readingsForInterval(_ interval: DateInterval) -> Results<GlucoseReading> {
        return allForCurrentMode.filter("date >= %@ AND date <= %@", interval.start, interval.end)
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
        
        let chartEntry = GlucoseChartEntry(reading: self)
        Realm.sharedCharts.safeWrite {
            Realm.sharedCharts.add(chartEntry, update: .modified)
        }
    }
    
    func updateIsCalibrated(_ isCalibrated: Bool) {
        Realm.shared.safeWrite {
            self.isCalibrated = isCalibrated
        }
    }
    
    func updateSourceInfo(_ info: String?) {
        Realm.shared.safeWrite {
            self.sourceInfo = info
        }
    }
    
    func appendSourceInfo(_ info: String?) {
        if sourceInfo == nil || sourceInfo?.isEmpty == true {
            updateSourceInfo(info)
        } else {
            guard let info = info, !info.isEmpty else { return }
            guard let sourceInfo = sourceInfo else { return }
            
            if !sourceInfo.hasPrefix(info) && !sourceInfo.contains("::\(info)") {
                self.updateSourceInfo(sourceInfo + "::" + info)
            } else {
                LogController.log(
                    message: "[GlucoseReading]: Ignoring duplicating source info %@ with -> %@",
                    type: .info,
                    sourceInfo,
                    info
                )
            }
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
    
    func updateDate(_ date: Date) {
        Realm.shared.safeWrite {
            self.date = date
        }
        
        let chartEntry = GlucoseChartEntry(reading: self)
        Realm.sharedCharts.safeWrite {
            Realm.sharedCharts.add(chartEntry, update: .modified)
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
        let last2Readings = GlucoseReading.lastReadings(2, for: .main)
        
        Realm.shared.safeWrite {
            if last2Readings.count >= 2 {
                calculatedValueSlope = calculateSlope(lastReading: last2Readings[1])
            } else {
                calculatedValueSlope = 0.0
            }
        }
        
        let chartEntry = GlucoseChartEntry(reading: self)
        Realm.sharedCharts.safeWrite {
            Realm.sharedCharts.add(chartEntry, update: .modified)
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
        let last3 = GlucoseReading.lastReadings(3, for: .main)
        
        let a: Double
        let b: Double
        let c: Double
        
        if last3.count >= 3 {
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
        
        let chartEntry = GlucoseChartEntry(reading: self)
        Realm.sharedCharts.safeWrite {
            Realm.sharedCharts.add(chartEntry, update: .modified)
        }
    }
    
    func activeSlope(date: Date = Date()) -> Double {
        return 2.0 * a * date.timeIntervalSince1970 + b
    }
    
    private func calculateNoise() {
        let mode = User.current.settings.deviceMode
        let maxRecords = 8
        let minRecords = 4
        
        let readings = GlucoseReading.lastReadings(maxRecords, for: mode).sorted(byKeyPath: "date", ascending: true)
        if readings.count < minRecords {
            Realm.shared.safeWrite {
                noise = "1" // Clean
            }
            return
        }
        
        let firstReading = readings[0]
        let lastReading = readings[readings.count - 1]
        
        let firstCalculatedValue = firstReading.calculatedValue
        let lastCalculatedValue = lastReading.calculatedValue
        
        if lastCalculatedValue > 400.0 {
            Realm.shared.safeWrite {
                noise = "3" // Medium
            }
            return
        } else if lastCalculatedValue < 40.0 {
            Realm.shared.safeWrite {
                noise = "2" // Light
            }
            return
        } else if abs(lastCalculatedValue - readings[readings.count - 2].calculatedValue) > 30.0 {
            Realm.shared.safeWrite {
                noise = "4" // Heavy
            }
            return
        }
        
        guard let firstDate = firstReading.date else { return }
        guard let lastDate = lastReading.date else { return }
        
        let firstSGV = firstCalculatedValue
        let firstTime = firstDate.timeIntervalSince1970 * 30.0
        
        let lastSGV = lastCalculatedValue
        let lastTime = lastDate.timeIntervalSince1970 * 30.0
        
        var xArray = [Double]()
        
        for reading in readings {
            guard let date = reading.date else { continue }
            xArray.append(date.timeIntervalSince1970 * 30.0 - firstTime)
        }
        
        var sumOfDistances = 0.0
        var lastDelta = 0.0
        
        for index in 1..<readings.count {
            var y2y1Delta = (readings[index].calculatedValue - readings[index - 1].calculatedValue)
                * (1.0 + Double(index) / Double(readings.count * 3))
            let x2x1Delta = xArray[index] - xArray[index - 1]
            if (lastDelta > 0.0 && y2y1Delta < 0.0) || (lastDelta < 0.0 && y2y1Delta > 0.0) {
                y2y1Delta *= 1.4
            }
            
            lastDelta = y2y1Delta
            sumOfDistances += sqrt(pow(x2x1Delta, 2.0) + pow(y2y1Delta, 2.0))
        }
        
        let overallSod = sqrt(pow(lastSGV - firstSGV, 2.0) + pow(lastTime - firstTime, 2.0))
        
        guard sumOfDistances !~ 0.0 else {
            Realm.shared.safeWrite {
                noise = "1"
            }
            return
        }
        
        let internalNoise = 1.0 - (overallSod / sumOfDistances)
        
        Realm.shared.safeWrite {
            if internalNoise < 0.15 {
                noise = "1"
            } else if internalNoise < 0.3 {
                noise = "2"
            } else if internalNoise < 0.5 {
                noise = "3"
            } else if internalNoise >= 0.5 {
                noise = "4"
            } else {
                noise = "1"
            }
        }
    }
    
    private func injectDisplayGlucose() {
        guard let displayGlucose = DisplayGlucose(readings: GlucoseReading.lastReadings(2, for: .main)) else {
            return
        }
        
        Realm.shared.safeWrite {
            self.displayGlucose = displayGlucose.mgDl
            displaySlope = displayGlucose.slope
            displayDeltaName = displayGlucose.deltaName
        }
    }
}

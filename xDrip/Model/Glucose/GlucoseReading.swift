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

protocol BaseGlucoseReading {
    var date: Date? { get }
    var calculatedValue: Double { get }
    var filteredCalculatedValue: Double { get }
    var calculatedValueSlope: Double { get }
    var deviceMode: UserDeviceMode { get }
}

final class GlucoseReading: Object, BaseGlucoseReading {
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
    @objc private(set) dynamic var rawCalibrationState: String?
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
    
    var isValid: Bool {
        return calibrationState == .okay || calibrationState == .needsCalibration || calibrationState == nil
    }
    
    override class func primaryKey() -> String? {
        return "externalID"
    }
    
    private static var emptyReadingsArray = Realm.shared.objects(GlucoseReading.self).filter(NSPredicate(value: false))
    
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
    
    var calibrationState: DexcomG6CalibrationState? {
        get {
            guard let calibrationStateValue = rawCalibrationState,
                  let rawState = UInt8(calibrationStateValue),
                  let state = DexcomG6CalibrationState(rawValue: rawState) else { return nil }
            return state
        }
        set {
            if let state = newValue {
                rawCalibrationState = String(state.rawValue)
            }
        }
    }
    
    required init() {
        super.init()
    }
    
    static func allGlucoseReadings(valid: Bool = true) -> Results<GlucoseReading> {
        return valid ?
            Realm.shared.objects(GlucoseReading.self).filter(.valid).sorted(by: [.dateDescending])
            :
            Realm.shared.objects(GlucoseReading.self).sorted(by: [.dateDescending])
    }
    
    static func allMaster(valid: Bool = true) -> Results<GlucoseReading> {
        return allGlucoseReadings(valid: valid)
            .filter(.deviceMode(mode: .main))
    }
    
    static func allMasterForCurrentSensor(valid: Bool = true) -> Results<GlucoseReading> {
        guard CGMDevice.current.isSensorStarted else { return emptyReadingsArray }
        guard let sensorStartDate = CGMDevice.current.sensorStartDate else { return emptyReadingsArray }
        return allMaster(valid: valid).filter(.laterThan(date: sensorStartDate))
    }
    
    static func lastReadings(_ amount: Int, mode: UserDeviceMode? = nil, valid: Bool = true) -> [GlucoseReading] {
        return last(amount: amount,
                    filter: NSCompoundPredicate(type: .and, subpredicates: [.calculatedValue, .rawValue]),
                    valid: valid,
                    for: mode)
    }
    
    static func latestByCount(_ amount: Int, mode: UserDeviceMode, valid: Bool = true) -> [GlucoseReading] {
        return last(amount: amount, filter: .rawValue, valid: valid, for: mode)
    }
    
    private static func last(amount: Int,
                             filter: NSPredicate,
                             valid: Bool = true,
                             for mode: UserDeviceMode? = nil) -> [GlucoseReading] {
        guard amount > 0 else { return [] }
        
        func allReadings(filteredBy filter: NSPredicate, mode: UserDeviceMode? = nil) -> Results<GlucoseReading> {
            var subpredicates = [filter]
            
            if let mode = mode {
                subpredicates.append(.deviceMode(mode: mode))
            }
            
            let andPredicate = NSCompoundPredicate(type: .and, subpredicates: subpredicates)
            return allGlucoseReadings(valid: valid).filter(andPredicate)
        }
        
        let readings = allReadings(filteredBy: filter, mode: mode).sorted(by: [.dateDescending])
        if readings.count > amount {
            return Array(readings[0..<amount])
        }
        return Array(readings)
    }
    
    static func masterForCurrentSensorInLast30MinutesCount(valid: Bool = true) -> Int {
        guard CGMDevice.current.isSensorStarted else { return 0 }
        guard let sensorStartDate = CGMDevice.current.sensorStartDate else { return 0 }
        let thirtyMinutesAgo = Date().addingTimeInterval(-(.secondsPerHour / 2))
        let andPredicate = NSCompoundPredicate(type: .and,
                                               subpredicates: [
                                                .deviceMode(mode: .main),
                                                .laterThan(date: sensorStartDate),
                                                .laterThan(date: thirtyMinutesAgo)
                                               ])
        return allGlucoseReadings(valid: valid).filter(andPredicate).count
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
        
        guard User.current.settings.deviceMode == .main else {
            LogController.log(message: "[Glucose] Can't create reading, deviceMode is not main(master)", type: .error)
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
        
        let realm = Realm.shared
        realm.safeWrite {
            realm.add(reading)
        }
        
        reading.findNewCurve()
        reading.findNewRawCurve()
        
        Calibration.adjustRecentReadings(1)
        reading.calculateNoise()
        reading.injectDisplayGlucose()
        checkForCalibrationRequest(requireCalibration)
        NightscoutService.shared.scanForNotUploadedEntries()
        
        LogController.log(
            message: "[Glucose] Created reading with calculated value: %@",
            type: .debug,
            "\(reading.calculatedValue)"
        )
        clearOldReadings()
        return reading
    }
    
    static func clearOldReadings() {
        let readingsPerDay = Int(TimeInterval.secondsPerDay / Constants.dexcomPeriod)
        let allReadings = allGlucoseReadings(valid: false)
        guard allReadings.count > readingsPerDay,
              let lastReading = allReadings.last,
              let lastReadingDate = lastReading.date,
              lastReadingDate < Date().addingTimeInterval(-.secondsPerDay) else {
            return
        }
        
        let realm = Realm.shared
        realm.safeWrite {
            if lastReading.isValid {
                realm.add(LightGlucoseReading(reading: lastReading))
            }
            realm.delete(lastReading)
        }
    }
    
    @discardableResult static func createFromG6(calculatedValue: Double,
                                                calibrationState: DexcomG6CalibrationState?,
                                                date: Date,
                                                forBackfill: Bool = false,
                                                requireCalibration: Bool = true) -> GlucoseReading? {
        LogController.log(message: "[Glucose] Trying to createFromG6 reading...", type: .debug)
        
        guard let sensorStarted = CGMDevice.current.sensorStartDate, CGMDevice.current.isSensorStarted else {
            LogController.log(message: "[Glucose] Can't create reading, sensor not started", type: .error)
            return nil
        }
        
        guard calculatedValue > .ulpOfOne else {
            LogController.log(message: "[Glucose] Can't createFromG6 reading, calculatedValue is below zero",
                              type: .error)
            return nil
        }
        
        guard User.current.settings.deviceMode == .main else {
            LogController.log(message: "[Glucose] Can't createFromG6 reading, deviceMode is not main(master)", type: .error)
            return nil
        }
        
        let reading = GlucoseReading()
        reading.externalID = UUID().uuidString
        reading.calculatedValue = calculatedValue
        reading.filteredCalculatedValue = calculatedValue
        reading.rawValue = calculatedValue
        reading.calibrationState = calibrationState
        reading.date = date
        reading.timeSinceSensorStarted = date.timeIntervalSince1970 - sensorStarted.timeIntervalSince1970
        reading.calculateAgeAdjustedRawValue()
        reading.findSlope()
        reading.sourceInfo = CGMDevice.current.deviceType?.title ?? "" + (forBackfill ? "Backfill" : "")
        
        if let settings = User.current.settings.nightscoutSync, settings.isEnabled,
           !forBackfill {
            reading.cloudUploadStatus = .notUploaded
        }
        
        Realm.shared.safeWrite {
            Realm.shared.add(reading)
        }
        
        reading.findNewCurve()
        reading.findNewRawCurve()
        
        LogController.log(
            message: "[Glucose] Created FromG6 reading with calculated value: %@, backfill: %@",
            type: .debug,
            "\(reading.calculatedValue)",
            forBackfill.description
        )
        
        if !forBackfill {
            checkForCalibrationRequest(requireCalibration, calibrationState: calibrationState)
            NightscoutService.shared.scanForNotUploadedEntries()
        }
        
        clearOldReadings()
        
        return reading
    }
    
    private static func checkForCalibrationRequest(_ requireCalibration: Bool,
                                                   calibrationState: DexcomG6CalibrationState? = nil) {
        if let calibrationState = calibrationState {
            switch calibrationState {
            case .needsFirstCalibration:
                CalibrationController.shared.requestInitialCalibration()
                return
            case .needsSecondCalibration, .needsCalibration:
                CalibrationController.shared.requestRegularCalibration()
                return
            default: return
            }
        }
        
        if Calibration.allForCurrentSensor.isEmpty
            && GlucoseReading.allMasterForCurrentSensor().count >= 2
            && requireCalibration {
            CalibrationController.shared.requestInitialCalibration()
        } else if CalibrationController.shared.canShowNextRegularCalibrationRequest() &&
                    CalibrationController.shared.isOptimalConditionToCalibrate() &&
                    masterForCurrentSensorInLast30MinutesCount() >= 2 {
            CalibrationController.shared.requestRegularCalibration()
        }
    }
    
    static func reading(for date: Date, precisionInMinutes: Int = 15, lockToSensor: Bool = false) -> GlucoseReading? {
        let allowedOffset = TimeInterval.secondsPerMinute * Double(precisionInMinutes)
        let minOffset = date - allowedOffset
        let maxOffset = date + allowedOffset
        let matching = allMaster(valid: false).filter { $0.date >? minOffset && $0.date <? maxOffset }
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
        guard let last = lastReadings(1, mode: .main).first else { return 160.0 }
        return last.ra * pow(date.timeIntervalSince1970, 2) + last.rb * date.timeIntervalSince1970 + last.rc
    }
    
    static func markEntryAsUploaded(externalID: String) {
        guard let entry = allMaster().first(where: { $0.externalID == externalID }) else {
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
        return allGlucoseReadings().filter(
            NSCompoundPredicate(type: .and, subpredicates: [
                .laterThanOrEqual(date: interval.start),
                .earlierThanOrEqual(date: interval.end)
            ]))
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
    
    func setFilteredCalculatedValue(_ value: Double) {
        self.filteredCalculatedValue = value
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
    }
    
    func setDate(_ date: Date) {
        self.date = date
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
        let last2Readings = GlucoseReading.lastReadings(2, mode: .main)
        
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
        if adjustFor > 0 {
            let factor = GlucoseReading.ageAdjustmentFactor
            let time = GlucoseReading.ageAdjustmentTime
            ageAdjustedRawValue = ((factor * (adjustFor / time)) * rawValue) + rawValue
        } else {
            ageAdjustedRawValue = rawValue
        }
    }
    
    private func findCurve(valueKey: String, bKey: String) -> (a: Double, b: Double, c: Double) {
        let last3 = GlucoseReading.lastReadings(3, mode: .main)
        
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
    
    func activeSlope(date: Date = Date()) -> Double {
        return 2 * a * date.timeIntervalSince1970 + b
    }
    
    private func calculateNoise() {
        let maxRecords = 8
        
        let minRecords = 4
        
        let readings = Array(GlucoseReading.lastReadings(maxRecords, mode: .main).reversed())
        
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
        guard let displayGlucose = DisplayGlucose(readings: GlucoseReading.lastReadings(2, mode: .main)) else {
            return
        }
        
        Realm.shared.safeWrite {
            self.displayGlucose = displayGlucose.mgDl
            displaySlope = displayGlucose.slope
            displayDeltaName = displayGlucose.deltaName
        }
    }
}

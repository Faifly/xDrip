//
//  Calibration.swift
//  xDrip
//
//  Created by Artem Kalmykov on 01.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift
import AKUtils

// swiftlint:disable identifier_name
// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
// swiftlint:disable closure_body_length
// swiftlint:disable file_length

enum CalibrationError: Error {
    case notEnoughReadings
    case sensorNotStarted
    case noReadingsNearDate
}

final class Calibration: Object {
    @objc private(set) dynamic var date: Date?
    @objc private(set) dynamic var rawDate: Date?
    @objc private(set) dynamic var sensorAge: Double = 0.0
    @objc private(set) dynamic var glucoseLevel: Double = 0.0
    @objc private(set) dynamic var rawValue: Double = 0.0
    @objc private(set) dynamic var adjustedRawValue: Double = 0.0
    @objc private(set) dynamic var sensorConfidence: Double = 0.0
    @objc private(set) dynamic var slopeConfidence: Double = 0.0
    @objc private(set) dynamic var slope: Double = 0.0
    @objc private(set) dynamic var intercept: Double = 0.0
    @objc private(set) dynamic var distanceFromEstimate: Double = 0.0
    @objc private(set) dynamic var estimatedRawAtTimeOfCalibration: Double = 0.0
    @objc private(set) dynamic var estimatedGlucoseAtTimeOfCalibration: Double = 0.0
    @objc private(set) dynamic var isPossibleBad: Bool = false
    @objc private(set) dynamic var checkIn: Bool = false
    @objc private(set) dynamic var firstDecay: Double = 0.0
    @objc private(set) dynamic var secondDecay: Double = 0.0
    @objc private(set) dynamic var firstSlope: Double = 0.0
    @objc private(set) dynamic var secondSlope: Double = 0.0
    @objc private(set) dynamic var firstIntercept: Double = 0.0
    @objc private(set) dynamic var secondIntercept: Double = 0.0
    @objc private(set) dynamic var firstScale: Double = 0.0
    @objc private(set) dynamic var secondScale: Double = 0.0
    @objc private(set) dynamic var isUploaded: Bool = false
    @objc private(set) dynamic var externalID: String?
    
    override class func primaryKey() -> String? {
        return "externalID"
    }
    
    static var all: [Calibration] {
        return Array(Realm.shared.objects(Calibration.self).sorted(byKeyPath: "date", ascending: false))
    }
    
    static var allForCurrentSensor: [Calibration] {
        guard CGMDevice.current.isSensorStarted else { return [] }
        guard let sensorStartDate = CGMDevice.current.sensorStartDate else { return [] }
        return all.filter { $0.date >? sensorStartDate }
    }
    
    static func lastCalibrations(_ amount: Int) -> [Calibration] {
        guard amount > 0 else { return [] }
        
        let allCalibrations = allForCurrentSensor
        if allCalibrations.count > amount {
            return Array(allCalibrations[0..<amount])
        }
        
        return Array(allCalibrations)
    }
    
    static var lastValid: Calibration? {
        return allForCurrentSensor.first {
            $0.slopeConfidence !~ 0 &&
            $0.sensorConfidence !~ 0 &&
            $0.slope !~ 0 &&
            $0.intercept <= SlopeParameters.highestSaneIntercept
        }
    }
    
    static func calibration(for date: Date) -> Calibration? {
        return allForCurrentSensor.first(
            where: {
                $0.slopeConfidence !~ 0 &&
                $0.sensorConfidence !~ 0 &&
                $0.date <? date
            }
        )
    }
    
    static func createInitialCalibration(
        glucoseLevel1: Double,
        glucoseLevel2: Double,
        date1: Date,
        date2: Date,
        adjustedReadingsAmount: Int = 5
    ) throws {
        let last2Readings = GlucoseReading.latestByCount(2, for: .main)
        guard last2Readings.count == 2 else { throw CalibrationError.notEnoughReadings }
        guard let sensorStarted = CGMDevice.current.sensorStartDate else { throw CalibrationError.sensorNotStarted }
        guard CGMDevice.current.isSensorStarted else { throw CalibrationError.sensorNotStarted }
        
        clearAllExistingCalibrations()
        
        let highLevel = max(glucoseLevel1, glucoseLevel2)
        var lowLevel = min(glucoseLevel1, glucoseLevel2)
        
        if lowLevel ~ highLevel {
            lowLevel -= .ulpOfOne * 1000.0
        }
        
        let highDate = highLevel ~ glucoseLevel1 ? date1 : date2
        let lowDate = highLevel ~ glucoseLevel2 ? date1 : date2
        
        let sensorAgeHigh = highDate.timeIntervalSince1970 - sensorStarted.timeIntervalSince1970
        let sensorAgeLow = lowDate.timeIntervalSince1970 - sensorStarted.timeIntervalSince1970
        
        let highReading: GlucoseReading
        let lowReading: GlucoseReading
        if last2Readings[0].rawValue > last2Readings[1].rawValue {
            highReading = last2Readings[0]
            lowReading = last2Readings[1]
        } else {
            highReading = last2Readings[1]
            lowReading = last2Readings[0]
        }
        
        let highCalibration = Calibration()
        highCalibration.date = highDate
        highCalibration.glucoseLevel = highLevel
        highCalibration.slope = 1.0
        highCalibration.intercept = highLevel
        highCalibration.estimatedRawAtTimeOfCalibration = highReading.ageAdjustedRawValue
        highCalibration.adjustedRawValue = highReading.ageAdjustedRawValue
        highCalibration.rawValue = highReading.rawValue
        highCalibration.rawDate = highReading.date
        highCalibration.sensorAge = sensorAgeHigh
        highCalibration.externalID = UUID().uuidString
        
        highReading.updateCalculatedValue(highLevel)
        highReading.updateIsCalibrated(true)
        highReading.updateCalibration(highCalibration)
        
        let lowCalibration = Calibration()
        lowCalibration.date = lowDate
        lowCalibration.glucoseLevel = lowLevel
        lowCalibration.slope = 1.0
        lowCalibration.intercept = lowLevel
        lowCalibration.estimatedRawAtTimeOfCalibration = lowReading.ageAdjustedRawValue
        lowCalibration.adjustedRawValue = lowReading.ageAdjustedRawValue
        lowCalibration.rawValue = lowReading.rawValue
        lowCalibration.rawDate = lowReading.date
        lowCalibration.sensorAge = sensorAgeLow
        lowCalibration.externalID = UUID().uuidString
        
        lowReading.updateCalculatedValue(lowLevel)
        lowReading.updateIsCalibrated(true)
        lowReading.updateCalibration(lowCalibration)
        
        highReading.findNewCurve()
        highReading.findNewRawCurve()
        lowReading.findNewCurve()
        lowReading.findNewRawCurve()
        
        for calibration in [lowCalibration, highCalibration] {
            Realm.shared.safeWrite {
                calibration.slopeConfidence = 0.5
                calibration.distanceFromEstimate = 0.0
                calibration.sensorConfidence = ((-0.0018 * pow(glucoseLevel1, 2))
                    + (0.6657 * glucoseLevel1)
                    + 36.7505) / 100.0
                Realm.shared.add(calibration)
            }
            Calibration.calculateWLS(date: calibration.date ?? Date())
        }
        
        adjustRecentReadings(adjustedReadingsAmount)
        
        NightscoutService.shared.scanForNotUploadedEntries()
    }
    
    static func createRegularCalibration(glucoseLevel: Double, date: Date) throws {
        guard let reading = GlucoseReading.reading(for: date) else { throw CalibrationError.noReadingsNearDate }
        guard let sensorStarted = CGMDevice.current.sensorStartDate else { throw CalibrationError.sensorNotStarted }
        guard CGMDevice.current.isSensorStarted else { throw CalibrationError.sensorNotStarted }
        
        let calibration = Calibration()
        calibration.glucoseLevel = glucoseLevel
        calibration.date = date
        calibration.rawValue = reading.rawValue
        calibration.adjustedRawValue = reading.ageAdjustedRawValue
        calibration.slopeConfidence = min(max(((4.0 - abs(reading.calculatedValueSlope * 60.0)) / 4.0), 0.0), 1.0)
        calibration.externalID = UUID().uuidString
        
        let estimatedRawGlucoseLevel = GlucoseReading.estimatedRawGlucoseLevel(date: Date())
        calibration.rawDate = reading.date
        if abs(estimatedRawGlucoseLevel - reading.ageAdjustedRawValue) > 20.0 {
            calibration.estimatedRawAtTimeOfCalibration = reading.ageAdjustedRawValue
        } else {
            calibration.estimatedRawAtTimeOfCalibration = estimatedRawGlucoseLevel
        }
        calibration.distanceFromEstimate = abs(calibration.glucoseLevel - reading.calculatedValue)
        calibration.sensorConfidence = max(
            ((-0.0018 * pow(glucoseLevel, 2)) + (0.6657 * glucoseLevel) + 36.7505) / 100.0,
            0.0
        )
        calibration.sensorAge = date.timeIntervalSince1970 - sensorStarted.timeIntervalSince1970
        
        Realm.shared.safeWrite {
            Realm.shared.add(calibration)
        }
        
        reading.updateCalibration(calibration)
        reading.updateIsCalibrated(true)
        reading.updateCalculatedValue(glucoseLevel)
        reading.updateFilteredCalculatedValue(glucoseLevel)
        calculateWLS()
        adjustRecentReadings(30)
        NightscoutService.shared.scanForNotUploadedEntries()
    }
    
    private static func clearAllExistingCalibrations() {
        let all = self.all
        Realm.shared.safeWrite {
            for calibration in all {
                calibration.slopeConfidence = 0.0
                calibration.sensorConfidence = 0.0
            }
        }
    }
    
    static func adjustRecentReadings(_ amount: Int) {
        let calibrations = lastCalibrations(3)
        let readings = GlucoseReading.latestByCount(amount, for: .main)
        
        if calibrations.count >= 3 {
            let denom = Double(readings.count)
            guard let latestCalibration = lastValid else { return }
            for (i, reading) in readings.enumerated() {
                let oldYValue = reading.calculatedValue
                let newYValue = (reading.ageAdjustedRawValue * latestCalibration.slope) + latestCalibration.intercept
                let newCalculatedValue = ((newYValue * (denom - Double(i))) + (oldYValue * Double(i))) / denom
                if reading.filteredCalculatedValue ~ reading.calculatedValue {
                    reading.updateFilteredCalculatedValue(newCalculatedValue)
                }
                reading.updateCalculatedValue(newCalculatedValue)
                reading.findSlope()
            }
        } else if calibrations.count == 2 {
            guard let latestCalibration = lastValid else { return }
            for reading in readings {
                let newYValue = reading.ageAdjustedRawValue * latestCalibration.slope + latestCalibration.intercept
                if reading.filteredCalculatedValue ~ reading.calculatedValue {
                    reading.updateFilteredCalculatedValue(newYValue)
                } else if reading.filteredCalculatedValue ~ 0 {
                    reading.updateFilteredCalculatedValue(newYValue)
                }
                reading.updateCalculatedValue(newYValue)
                reading.updateCalculatedValueToWithinMinMax()
                reading.findSlope()
            }
        }
        
        readings.first?.findNewRawCurve()
        readings.first?.findNewCurve()
    }
    
    static func deleteLast() {
        guard let last = allForCurrentSensor.first else { return }
        NightscoutService.shared.deleteCalibrations([last])
        let realm = Realm.shared
        realm.safeWrite {
            realm.delete(last)
        }
    }
    
    static func deleteAll() {
        let realm = Realm.shared
        let all = allForCurrentSensor
        NightscoutService.shared.deleteCalibrations(all)
        realm.safeWrite {
            realm.delete(all)
        }
    }
    
    static func markCalibrationAsUploaded(itemID: String) {
        guard let calibration = all.first(where: { $0.externalID == itemID }) else { return }
        Realm.shared.safeWrite {
            calibration.isUploaded = true
        }
    }
    
    private static func calculateWLS(date: Date = Date()) {
        let slopeParameters = SlopeParameters.dex
        let minDate = date.timeIntervalSince1970 - .secondsPerDay * 4.0
        let calibrations = all.filter {
            $0.date?.timeIntervalSince1970 >? minDate &&
            $0.sensorConfidence !~ 0 &&
            $0.slopeConfidence !~ 0
        }
        guard !calibrations.isEmpty else { return }
        
        guard calibrations.count > 1 else {
            let calibration = calibrations[0]
            Realm.shared.safeWrite {
                calibration.slope = 1.0
                calibration.intercept = calibration.glucoseLevel - (calibration.rawValue * calibration.slope)
            }
            return
        }
        
        var l = 0.0
        var m = 0.0
        var n = 0.0
        var p = 0.0
        var q = 0.0
        var w = 0.0
        
        for calibration in calibrations {
            w = calibration.calculateWeight()
            l += w
            m += w * calibration.estimatedRawAtTimeOfCalibration
            n += w * pow(calibration.estimatedRawAtTimeOfCalibration, 2)
            p += w * calibration.glucoseLevel
            q += w * calibration.estimatedRawAtTimeOfCalibration * calibration.glucoseLevel
        }
        
        let lastCalibration = calibrations[0]
        w = lastCalibration.calculateWeight() * Double(calibrations.count) * 0.14
        l += w
        m += w * lastCalibration.estimatedRawAtTimeOfCalibration
        n += w * pow(lastCalibration.estimatedRawAtTimeOfCalibration, 2)
        p += w * lastCalibration.glucoseLevel
        q += w * lastCalibration.estimatedRawAtTimeOfCalibration * lastCalibration.glucoseLevel
        
        let d = (l * n) - (m * m)
        
        Realm.shared.safeWrite {
            lastCalibration.intercept = ((n * p) - (m * q)) / d
            lastCalibration.slope = ((l * q) - (m * p)) / d
            
            if (calibrations.count == 2 && lastCalibration.slope < slopeParameters.lowSlope1)
                || (lastCalibration.slope < slopeParameters.lowSlope2) {
                lastCalibration.slope = lastCalibration.slopeOOBHandler(status: 0)
                if calibrations.count > 2 {
                    lastCalibration.isPossibleBad = true
                }
                lastCalibration.intercept = lastCalibration.glucoseLevel -
                    (lastCalibration.estimatedRawAtTimeOfCalibration * lastCalibration.slope)
            }
            
            if (calibrations.count == 2 && lastCalibration.slope > slopeParameters.highSlope1)
                || (lastCalibration.slope > slopeParameters.highSlope2) {
                lastCalibration.slope = lastCalibration.slopeOOBHandler(status: 1)
                if calibrations.count > 2 {
                    lastCalibration.isPossibleBad = true
                }
                lastCalibration.intercept = lastCalibration.glucoseLevel -
                    (lastCalibration.estimatedRawAtTimeOfCalibration * lastCalibration.slope)
            }
            
            if lastCalibration.slope.isNaN
                || lastCalibration.slope.isInfinite
                || lastCalibration.intercept.isNaN
                || lastCalibration.intercept.isInfinite {
                lastCalibration.sensorConfidence = 0.0
                lastCalibration.slopeConfidence = 0.0
            }
            
            if lastCalibration.slope ~ 0 && lastCalibration.intercept ~ 0 {
                lastCalibration.sensorConfidence = 0.0
                lastCalibration.slopeConfidence = 0.0
            } else if lastCalibration.intercept > SlopeParameters.highestSaneIntercept {
                // error
                LogController.log(message: "[ERROR] Intercept is higher than sane", type: .error)
            }
        }
    }
    
    private func calculateWeight() -> Double {
        let all = Calibration.allForCurrentSensor
        guard all.count > 1 else { return 1.0 }
        let lastTimeStarted = all[0].sensorAge
        let firstTimeStarted = all[all.count - 1].sensorAge
        if lastTimeStarted ~ firstTimeStarted {
            return 1.0
        }
        var timePercentage = min(((sensorAge - firstTimeStarted) / (lastTimeStarted - firstTimeStarted)) / 0.85, 1.0)
        timePercentage += 0.01
        return max((((((slopeConfidence + sensorConfidence) * timePercentage)) / 2.0) * 100.0), 1.0)
    }
    
    private func slopeOOBHandler(status: Int) -> Double {
        let slopeParameters = SlopeParameters.dex
        
        let calibrations = Calibration.lastCalibrations(3)
        guard !calibrations.isEmpty else { return 1.0 }
        let thisCalibration = calibrations[0]
        if status == 0 {
            if calibrations.count == 3 {
                if (abs(thisCalibration.glucoseLevel - thisCalibration.estimatedGlucoseAtTimeOfCalibration) < 30)
                    && calibrations[1].slope !~ 0
                    && calibrations[1].isPossibleBad {
                    return calibrations[1].slope
                } else {
                    return max(
                        (-0.048 * (thisCalibration.sensorAge / (TimeInterval.secondsPerDay))) + 1.1,
                        slopeParameters.defaultLowSlopeLow
                    )
                }
            } else if calibrations.count == 2 {
                return max(
                    (-0.048 * (thisCalibration.sensorAge / (TimeInterval.secondsPerDay))) + 1.1,
                    slopeParameters.defaultLowSlopeHigh
                )
            }
            return slopeParameters.defaultSlope
        } else {
            if calibrations.count == 3 {
                if (abs(thisCalibration.glucoseLevel - thisCalibration.estimatedGlucoseAtTimeOfCalibration) < 30)
                    && calibrations[1].slope !~ 0
                    && calibrations[1].isPossibleBad {
                    return calibrations[1].slope
                } else {
                    return slopeParameters.defaultHighSlopeHigh
                }
            } else if calibrations.count == 2 {
                return slopeParameters.defaultHighSlopeLow
            }
        }
        
        return slopeParameters.defaultSlope
    }
}

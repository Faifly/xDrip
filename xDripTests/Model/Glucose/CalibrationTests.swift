//
//  CalibrationTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 08.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
// swiftlint:disable force_unwrapping

final class CalibrationTests: AbstractRealmTest {
    func testFetchAll() {
        let calibration1 = Calibration()
        calibration1.setValue(Date(timeIntervalSince1970: 1.0), forKey: "date")
        calibration1.setValue(1.0, forKey: "rawValue")
        
        let calibration2 = Calibration()
        calibration2.setValue(Date(timeIntervalSince1970: 2.0), forKey: "date")
        calibration2.setValue(2.0, forKey: "rawValue")
        
        let calibration3 = Calibration()
        calibration3.setValue(Date(timeIntervalSince1970: 3.0), forKey: "date")
        calibration3.setValue(3.0, forKey: "rawValue")
        
        realm.safeWrite {
            realm.add([calibration1, calibration2, calibration3])
        }
        
        let all = Calibration.all
        
        XCTAssertTrue(all[0].rawValue ~ 3.0)
        XCTAssertTrue(all[1].rawValue ~ 2.0)
        XCTAssertTrue(all[2].rawValue ~ 1.0)
    }
    
    func testLastCalibrations() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "0"
        )
        
        XCTAssertTrue(Calibration.lastCalibrations(0).isEmpty)
        XCTAssertTrue(Calibration.lastCalibrations(1).isEmpty)
        XCTAssertTrue(Calibration.lastCalibrations(10).isEmpty)
        
        let calibration1 = Calibration()
        calibration1.setValue(Date(timeIntervalSince1970: 1.0), forKey: "date")
        calibration1.setValue(1.0, forKey: "rawValue")
        
        realm.safeWrite {
            realm.add(calibration1)
        }
        
        XCTAssertTrue(Calibration.lastCalibrations(0).isEmpty)
        XCTAssertTrue(Calibration.lastCalibrations(1).count == 1)
        XCTAssertTrue(Calibration.lastCalibrations(2).count == 1)
        
        let calibration2 = Calibration()
        calibration2.setValue(Date(timeIntervalSince1970: 2.0), forKey: "date")
        calibration2.setValue(2.0, forKey: "rawValue")
        
        realm.safeWrite {
            realm.add(calibration2)
        }
        
        XCTAssertTrue(Calibration.lastCalibrations(1).count == 1)
        XCTAssertTrue(Calibration.lastCalibrations(2).count == 2)
        XCTAssertTrue(Calibration.lastCalibrations(3).count == 2)
        
        let calibration3 = Calibration()
        calibration3.setValue(Date(timeIntervalSince1970: 3.0), forKey: "date")
        calibration3.setValue(3.0, forKey: "rawValue")
        
        realm.safeWrite {
            realm.add(calibration3)
        }
        
        XCTAssertTrue(Calibration.lastCalibrations(1).count == 1)
        XCTAssertTrue(Calibration.lastCalibrations(2).count == 2)
        XCTAssertTrue(Calibration.lastCalibrations(3).count == 3)
        XCTAssertTrue(Calibration.lastCalibrations(4).count == 3)
        
        let last3 = Calibration.lastCalibrations(3)
        
        XCTAssertTrue(last3[0].rawValue ~ 3.0)
        XCTAssertTrue(last3[1].rawValue ~ 2.0)
        XCTAssertTrue(last3[2].rawValue ~ 1.0)
    }
    
    func testLastValid() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "0"
        )
        
        XCTAssertNil(Calibration.lastValid)
        
        let calibration = Calibration()
        calibration.setValue(Date(), forKey: "date")
        realm.safeWrite {
            realm.add(calibration)
        }
        XCTAssertNil(Calibration.lastValid)
        
        realm.safeWrite {
            calibration.setValue(1.0, forKey: "slopeConfidence")
        }
        XCTAssertNil(Calibration.lastValid)
        
        realm.safeWrite {
            calibration.setValue(1.0, forKey: "sensorConfidence")
        }
        XCTAssertNil(Calibration.lastValid)
        
        realm.safeWrite {
            calibration.setValue(1.0, forKey: "slope")
        }
        XCTAssertNotNil(Calibration.lastValid)
        
        realm.safeWrite {
            calibration.setValue(SlopeParameters.highestSaneIntercept + 1.0, forKey: "intercept")
        }
        XCTAssertNil(Calibration.lastValid)
        
        let calibration2 = Calibration()
        calibration2.setValue(Date(timeIntervalSince1970: 5.0), forKey: "date")
        calibration2.setValue(2.0, forKey: "slope")
        calibration2.setValue(1.0, forKey: "slopeConfidence")
        calibration2.setValue(1.0, forKey: "sensorConfidence")
        
        realm.safeWrite {
            realm.add(calibration2)
            calibration.setValue(1.0, forKey: "intercept")
            calibration.setValue(Date(timeIntervalSince1970: 4.0), forKey: "date")
        }
        XCTAssert(Calibration.lastValid!.slope ~ 2.0)
        
        realm.safeWrite {
            calibration.setValue(Date(timeIntervalSince1970: 6.0), forKey: "date")
        }
        XCTAssert(Calibration.lastValid!.slope ~ 1.0)
    }
    
    func testCalibrationForDate() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "0"
        )
        
        XCTAssertNil(Calibration.calibration(for: Date()))
        
        let calibration1 = Calibration()
        calibration1.setValue(Date(timeIntervalSince1970: 10.0), forKey: "date")
        realm.safeWrite {
            realm.add(calibration1)
        }
        XCTAssertNil(Calibration.calibration(for: Date()))
        
        realm.safeWrite {
            calibration1.setValue(1.0, forKey: "slopeConfidence")
        }
        XCTAssertNil(Calibration.calibration(for: Date()))
        
        realm.safeWrite {
            calibration1.setValue(1.0, forKey: "sensorConfidence")
        }
        XCTAssertNotNil(Calibration.calibration(for: Date()))
        
        let calibration2 = Calibration()
        calibration2.setValue(Date(timeIntervalSince1970: 12.0), forKey: "date")
        calibration2.setValue(2.0, forKey: "slopeConfidence")
        calibration2.setValue(2.0, forKey: "sensorConfidence")
        
        realm.safeWrite {
            realm.add(calibration2)
        }
        
        XCTAssert(Calibration.calibration(for: Date())!.slopeConfidence ~ 2.0)
        XCTAssert(Calibration.calibration(for: Date(timeIntervalSince1970: 11.0))!.slopeConfidence ~ 1.0)
        XCTAssertNil(Calibration.calibration(for: Date(timeIntervalSince1970: 9.0)))
    }
    
    func testCreateInitialCalibration() {
        var now = Date()
        
        XCTAssertThrowsError(
            try Calibration.createInitialCalibration(
                glucoseLevel1: 0.0,
                glucoseLevel2: 0.0,
                date1: now,
                date2: now
        ), "") { error in
            XCTAssert((error as? CalibrationError) == .notEnoughReadings)
        }
        
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "0"
        )
        
        let reading1 = GlucoseReading()
        reading1.setValue(now - .secondsPerMinute * 5.0 - 1.0, forKey: "date")
        reading1.setValue(130.0, forKey: "rawValue")
        
        let reading2 = GlucoseReading()
        reading2.setValue(now - 1.0, forKey: "date")
        reading2.setValue(160.0, forKey: "rawValue")
        
        realm.safeWrite {
            realm.add([reading1, reading2])
        }
        
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "\((now - .secondsPerMinute * 10.0).timeIntervalSince1970)"
        )
        
        realm.safeWrite {
            reading1.setValue(135.0, forKey: "filteredValue")
            reading1.calculateAgeAdjustedRawValue()
            
            reading2.setValue(165.0, forKey: "filteredValue")
            reading2.calculateAgeAdjustedRawValue()
        }
        
        try? Calibration.createInitialCalibration(
            glucoseLevel1: 120.0,
            glucoseLevel2: 140.0,
            date1: now - .secondsPerMinute * 5.0,
            date2: now
        )
        
        let calibrations = Calibration.lastCalibrations(3)
        XCTAssert(calibrations.count == 2)
        
        var calibration1 = calibrations[0]
        let calibration2 = calibrations[1]
        
        XCTAssert(reading1.filteredValue ~ 135.0)
        XCTAssert(reading1.rawValue ~ 130.0)
        XCTAssert(reading1.calculatedValue ~~ 92.0)
        XCTAssert(reading1.filteredCalculatedValue ~~ 92.0)
        XCTAssert(reading1.isCalibrated)
        XCTAssert(reading1.a ~ 0.0)
        XCTAssert(reading1.b ~ 0.06666666666666667)
        XCTAssert(reading1.ra ~ 0.0)
        XCTAssert(reading1.rb ~ 0.145)
        XCTAssert(reading1.ageAdjustedRawValue ~ 188.5)
        XCTAssertFalse(reading1.hideSlope)
        XCTAssert(reading1.calculatedValueSlope ~ 0.0)
        XCTAssert(reading1.calibration!.sensorAge ~ calibration2.sensorAge)
        
        XCTAssert(reading2.filteredValue ~ 165.0)
        XCTAssert(reading2.rawValue ~ 160.0)
        XCTAssert(reading2.calculatedValue ~~ 140.0)
        XCTAssert(reading2.filteredCalculatedValue ~~ 140.0)
        XCTAssert(reading2.isCalibrated)
        XCTAssert(reading2.a ~ 0.0)
        XCTAssert(abs(reading2.b - 0.1594) < 0.0001)
        XCTAssert(reading2.ra ~ 0.0)
        XCTAssert(reading2.rb ~ 0.145)
        XCTAssert(reading2.ageAdjustedRawValue ~ 232.0)
        XCTAssertFalse(reading2.hideSlope)
        XCTAssert(reading2.calculatedValueSlope ~ 0.06666666666666667)
        XCTAssert(reading2.calibration!.sensorAge ~ calibration1.sensorAge)
        
        XCTAssert(calibration1.rawDate!.timeIntervalSince1970 ~ reading2.date!.timeIntervalSince1970)
        XCTAssert(calibration1.sensorAge ~ 600.0)
        XCTAssert(calibration1.glucoseLevel ~ 140.0)
        XCTAssert(calibration1.rawValue ~ 160.0)
        XCTAssert(calibration1.adjustedRawValue ~ 232.0)
        XCTAssert(calibration1.sensorConfidence ~ 0.907145)
        XCTAssert(calibration1.slopeConfidence ~ 0.5)
        XCTAssert(calibration1.slope ~ 1.099666666666667)
        XCTAssert(calibration1.intercept ~ -115.1226666666667)
        XCTAssert(calibration1.distanceFromEstimate ~ 0.0)
        XCTAssert(calibration1.estimatedRawAtTimeOfCalibration ~ 232.0)
        XCTAssert(calibration1.estimatedGlucoseAtTimeOfCalibration ~ 0.0)
        XCTAssertFalse(calibration1.isPossibleBad)
        XCTAssertFalse(calibration1.checkIn)
        
        XCTAssert(calibration2.rawDate!.timeIntervalSince1970 ~ reading1.date!.timeIntervalSince1970)
        XCTAssert(calibration2.sensorAge ~ 300.0)
        XCTAssert(calibration2.glucoseLevel ~ 120.0)
        XCTAssert(calibration2.rawValue ~ 130.0)
        XCTAssert(calibration2.adjustedRawValue ~ 188.5)
        XCTAssert(calibration2.sensorConfidence ~ 0.907145)
        XCTAssert(calibration2.slopeConfidence ~ 0.5)
        XCTAssert(calibration2.slope ~ 1.0)
        XCTAssert(calibration2.intercept ~ -10.0)
        XCTAssert(calibration2.distanceFromEstimate ~ 0.0)
        XCTAssert(calibration2.estimatedRawAtTimeOfCalibration ~ 188.5)
        XCTAssert(calibration2.estimatedGlucoseAtTimeOfCalibration ~ 0.0)
        XCTAssertFalse(calibration2.isPossibleBad)
        XCTAssertFalse(calibration2.checkIn)
        
        now = Date()
        try? Calibration.createInitialCalibration(
            glucoseLevel1: 140.0,
            glucoseLevel2: 120.0,
            date1: now,
            date2: now - .secondsPerMinute * 5.0
        )
        
        realm.safeWrite {
            reading2.setValue(130.0, forKey: "rawValue")
            reading2.setValue(135.0, forKey: "filteredValue")
            reading2.calculateAgeAdjustedRawValue()
            
            reading1.setValue(160.0, forKey: "rawValue")
            reading1.setValue(165.0, forKey: "filteredValue")
            reading1.calculateAgeAdjustedRawValue()
        }
        
        calibration1 = Calibration.lastValid!
        
        XCTAssert(calibration1.sensorAge ~~ 600.0)
    }
    
    func testCreateRegularCalibration() {
        let now = Date()
        XCTAssertThrowsError(
        try Calibration.createRegularCalibration(glucoseLevel: 0.0, date: now), "") { error in
            XCTAssert((error as? CalibrationError) == .noReadingsNearDate)
        }
        
        let reading1 = GlucoseReading()
        reading1.setValue(now - 1.0, forKey: "date")
        realm.safeWrite {
            realm.add(reading1)
        }
        
        XCTAssertThrowsError(
        try Calibration.createRegularCalibration(glucoseLevel: 0.0, date: now), "") { error in
            XCTAssert((error as? CalibrationError) == .sensorNotStarted)
        }
        
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "\((now - .secondsPerDay).timeIntervalSince1970)"
        )
        
        realm.safeWrite {
            realm.delete(reading1)
        }
        
        for index in 0..<30 {
            let filtered = 100.0 + Double(index) * 10.0
            let unfiltered = filtered - 5.0
            let date = now - TimeInterval(index) * .secondsPerMinute * 5.0 - 1.0
            GlucoseReading.create(filtered: filtered, unfiltered: unfiltered, date: date)
        }
        
        try? Calibration.createInitialCalibration(
            glucoseLevel1: 105.0,
            glucoseLevel2: 115.0,
            date1: now - TimeInterval(28) * .secondsPerMinute * 5.0,
            date2: now - TimeInterval(27) * .secondsPerMinute * 5.0
        )
        
        try? Calibration.createRegularCalibration(glucoseLevel: 160.0, date: now)
        
        let readings = GlucoseReading.lastReadings(30)
        let calibrations = Calibration.lastCalibrations(30)
        
        XCTAssert(readings.count == 30)
        XCTAssert(calibrations.count == 3)
        
        for reading in readings {
            XCTAssert(reading.calculatedValue > .ulpOfOne)
            XCTAssert(reading.filteredCalculatedValue > .ulpOfOne)
        }
    }
    
    func testInitialCalibrationRaising() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "\((Date() - .secondsPerMinute * 20.0).timeIntervalSince1970)"
        )
        
        addMockReading(rawData: 125.0, minutes: 11.0)
        addMockReading(rawData: 130.0, minutes: 6.0)
        addMockReading(rawData: 135.0, minutes: 1.0)
        
        try? Calibration.createInitialCalibration(
            glucoseLevel1: 140.0,
            glucoseLevel2: 145.0,
            date1: Date() - 0.005,
            date2: Date()
        )
        
        let calibrations = Calibration.lastCalibrations(3)
        XCTAssert(calibrations.count == 2)
        
        XCTAssert(calibrations[0].glucoseLevel ~ 145.0)
        XCTAssert(calibrations[0].rawValue ~ 135.0)
        XCTAssert(calibrations[0].slope ~ 1.0)
        XCTAssert(abs(calibrations[0].intercept - 9.9) < 0.00001)
        
        XCTAssert(calibrations[1].glucoseLevel ~ 140.0)
        XCTAssert(calibrations[1].rawValue ~ 130.0)
        XCTAssert(calibrations[1].slope ~ 1.0)
        XCTAssert(calibrations[1].intercept ~ 10.0)
    }
    
    func testInitialCalibrationFalling() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "\((Date() - .secondsPerMinute * 20.0).timeIntervalSince1970)"
        )
        
        addMockReading(rawData: 135.0, minutes: 11.0)
        addMockReading(rawData: 130.0, minutes: 6.0)
        addMockReading(rawData: 125.0, minutes: 1.0)
        
        try? Calibration.createInitialCalibration(
            glucoseLevel1: 145.0,
            glucoseLevel2: 140.0,
            date1: Date(),
            date2: Date() - 0.005
        )
        
        let calibrations = Calibration.lastCalibrations(3)
        XCTAssert(calibrations.count == 2)
        
        XCTAssert(calibrations[0].glucoseLevel ~ 145.0)
        XCTAssert(calibrations[0].rawValue ~ 130.0)
        XCTAssert(calibrations[0].slope ~ 1.0)
        XCTAssert(abs(calibrations[0].intercept - 14.9) < 0.00001)
        
        XCTAssert(calibrations[1].glucoseLevel ~ 140.0)
        XCTAssert(calibrations[1].rawValue ~ 125.0)
        XCTAssert(calibrations[1].slope ~ 1.0)
        XCTAssert(calibrations[1].intercept ~ 15.0)
    }
    
    private func addMockReading(rawData: Double, minutes: Double) {
        let reading = GlucoseReading()
        reading.setValue(rawData, forKey: "rawValue")
        reading.setValue(Date() - minutes * .secondsPerMinute, forKey: "date")
        reading.setValue(rawData + 0.1, forKey: "ageAdjustedRawValue")
        realm.safeWrite {
            realm.add(reading)
        }
    }
}

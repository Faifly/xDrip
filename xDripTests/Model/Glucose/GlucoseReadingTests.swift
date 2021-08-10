//
//  GlucoseReadingTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable file_length
// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
// swiftlint:disable force_unwrapping

final class GlucoseReadingTests: AbstractRealmTest {
    func testFetchingAll() {
        let reading1 = GlucoseReading()
        reading1.setValue(Date(timeIntervalSince1970: 1.0), forKey: "date")
        reading1.setValue(1.0, forKey: "a")
        reading1.generateID()
        
        let reading2 = GlucoseReading()
        reading2.setValue(Date(timeIntervalSince1970: 2.0), forKey: "date")
        reading2.setValue(2.0, forKey: "a")
        reading2.generateID()
        
        let reading3 = GlucoseReading()
        reading3.setValue(Date(timeIntervalSince1970: 3.0), forKey: "date")
        reading3.setValue(3.0, forKey: "a")
        reading3.generateID()
        
        realm.safeWrite {
            realm.add([reading1, reading2, reading3])
        }
        
        let all = GlucoseReading.allMaster()
        
        XCTAssertTrue(all[0].a ~ 3.0)
        XCTAssertTrue(all[1].a ~ 2.0)
        XCTAssertTrue(all[2].a ~ 1.0)
    }
    
    func testLastReadings() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "0"
        )
        CGMDevice.current.updateSensorIsStarted(true)
        
        XCTAssertTrue(GlucoseReading.lastReadings(0, for: .main).isEmpty)
        XCTAssertTrue(GlucoseReading.lastReadings(1, for: .main).isEmpty)
        XCTAssertTrue(GlucoseReading.lastReadings(10, for: .main).isEmpty)
        
        let reading1 = GlucoseReading()
        reading1.setValue(Date(timeIntervalSince1970: 1.0), forKey: "date")
        reading1.setValue(1.0, forKey: "a")
        reading1.generateID()
        
        realm.safeWrite {
            realm.add(reading1)
        }
        
        XCTAssertTrue(GlucoseReading.lastReadings(1, for: .main).isEmpty)
        
        realm.safeWrite {
            reading1.setValue(1.0, forKey: "rawValue")
        }
        
        XCTAssertTrue(GlucoseReading.lastReadings(1, for: .main).isEmpty)
        
        realm.safeWrite {
            reading1.setValue(1.0, forKey: "calculatedValue")
        }
        
        XCTAssertTrue(GlucoseReading.lastReadings(0, for: .main).isEmpty)
        XCTAssertTrue(GlucoseReading.lastReadings(1, for: .main).count == 1)
        XCTAssertTrue(GlucoseReading.lastReadings(2, for: .main).count == 1)
        
        let reading2 = GlucoseReading()
        reading2.setValue(Date(timeIntervalSince1970: 2.0), forKey: "date")
        reading2.setValue(2.0, forKey: "a")
        reading2.setValue(1.0, forKey: "rawValue")
        reading2.setValue(1.0, forKey: "calculatedValue")
        reading2.generateID()
        
        realm.safeWrite {
            realm.add(reading2)
        }
        
        XCTAssertTrue(GlucoseReading.lastReadings(1, for: .main).count == 1)
        XCTAssertTrue(GlucoseReading.lastReadings(2, for: .main).count == 2)
        XCTAssertTrue(GlucoseReading.lastReadings(3, for: .main).count == 2)
        
        let reading3 = GlucoseReading()
        reading3.setValue(Date(timeIntervalSince1970: 3.0), forKey: "date")
        reading3.setValue(3.0, forKey: "a")
        reading3.setValue(1.0, forKey: "rawValue")
        reading3.setValue(1.0, forKey: "calculatedValue")
        reading3.generateID()
        
        realm.safeWrite {
            realm.add(reading3)
        }
        
        XCTAssertTrue(GlucoseReading.lastReadings(1, for: .main).count == 1)
        XCTAssertTrue(GlucoseReading.lastReadings(2, for: .main).count == 2)
        XCTAssertTrue(GlucoseReading.lastReadings(3, for: .main).count == 3)
        XCTAssertTrue(GlucoseReading.lastReadings(4, for: .main).count == 3)
        
        let last3 = GlucoseReading.lastReadings(3, for: .main)
        
        XCTAssertTrue(last3[0].a ~ 3.0)
        XCTAssertTrue(last3[1].a ~ 2.0)
        XCTAssertTrue(last3[2].a ~ 1.0)
    }
    
    func testCreation() {
        // Sensor not started
        XCTAssertNil(GlucoseReading.create(filtered: 0.0, unfiltered: 0.0, rssi: 0.0))
        
        let now = Date()
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "\((Date() - .secondsPerDay).timeIntervalSince1970)"
        )
        CGMDevice.current.updateSensorIsStarted(true)
        
        let reading1 = GlucoseReading.create(filtered: 140000.0, unfiltered: 135000.0, rssi: 0.0)!
        XCTAssertNotNil(reading1)
        XCTAssert(reading1.filteredValue ~ 140.0)
        XCTAssert(reading1.rawValue ~ 135.0)
        XCTAssert(reading1.date!.timeIntervalSince1970 ~~ now.timeIntervalSince1970)
        XCTAssert(reading1.calculatedValue ~ 0.0)
        XCTAssert(reading1.filteredCalculatedValue ~ 0.0)
        XCTAssertFalse(reading1.isCalibrated)
        XCTAssert(reading1.a ~ 0.0)
        XCTAssert(reading1.b ~ 0.0)
        XCTAssert(reading1.c ~ 0.0)
        XCTAssert(reading1.ra ~ 0.0)
        XCTAssert(reading1.rb ~ 0.0)
        XCTAssert(reading1.rc ~~ 163.77)
        XCTAssert(reading1.ageAdjustedRawValue ~~ 163.77)
        XCTAssertNil(reading1.calibration)
        XCTAssertFalse(reading1.hideSlope)
        XCTAssert(reading1.calculatedValueSlope ~ 0.0)
        XCTAssert(reading1.timeSinceSensorStarted ~~ .secondsPerDay)
        
        let reading2 = GlucoseReading.create(filtered: 150000.0, unfiltered: 145000.0, rssi: 0.0)!
        XCTAssertNotNil(reading2)
        XCTAssert(reading2.filteredValue ~ 150.0)
        XCTAssert(reading2.rawValue ~ 145.0)
        XCTAssert(reading2.date!.timeIntervalSince1970 ~~ now.timeIntervalSince1970)
        XCTAssert(reading2.calculatedValue ~ 0.0)
        XCTAssert(reading2.filteredCalculatedValue ~ 0.0)
        XCTAssertFalse(reading2.isCalibrated)
        XCTAssert(reading2.a ~ 0.0)
        XCTAssert(reading2.b ~ 0.0)
        XCTAssert(reading2.c ~ 0.0)
        XCTAssert(reading2.ra ~ 0.0)
        XCTAssert(reading2.rb ~ 0.0)
        XCTAssert(reading2.rc ~~ 175.0)
        XCTAssert(reading2.ageAdjustedRawValue ~~ 175.9)
        XCTAssertNil(reading2.calibration)
        XCTAssertFalse(reading2.hideSlope)
        XCTAssert(reading2.calculatedValueSlope ~ 0.0)
        XCTAssert(reading2.timeSinceSensorStarted ~~ .secondsPerDay)
        
        let reading3 = GlucoseReading.create(filtered: 160000.0, unfiltered: 155000.0, rssi: 0.0)!
        XCTAssertNotNil(reading3)
        XCTAssert(reading3.filteredValue ~ 160.0)
        XCTAssert(reading3.rawValue ~ 155.0)
        XCTAssert(reading3.date!.timeIntervalSince1970 ~~ now.timeIntervalSince1970)
        XCTAssert(reading3.calculatedValue ~ 0.0)
        XCTAssert(reading3.filteredCalculatedValue ~ 0.0)
        XCTAssertFalse(reading3.isCalibrated)
        XCTAssert(reading3.a ~ 0.0)
        XCTAssert(reading3.b ~ 0.0)
        XCTAssert(reading3.c ~ 0.0)
        XCTAssert(reading3.ra ~ 0.0)
        XCTAssert(reading3.rb ~ 0.0)
        XCTAssert(reading3.rc ~~ 188.0)
        XCTAssert(reading3.ageAdjustedRawValue ~~ 188.03)
        XCTAssertNil(reading3.calibration)
        XCTAssertFalse(reading3.hideSlope)
        XCTAssert(reading3.calculatedValueSlope ~ 0.0)
        XCTAssert(reading3.timeSinceSensorStarted ~~ .secondsPerDay)
    }
    
    func testReadingCreationWithCalibration() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "\((Date() - .secondsPerDay).timeIntervalSince1970)"
        )
        CGMDevice.current.updateSensorIsStarted(true)
        let calibration = Calibration()
        calibration.setValue(Date(), forKey: "date")
        calibration.setValue(1.0, forKey: "slopeConfidence")
        calibration.setValue(1.0, forKey: "sensorConfidence")
        realm.safeWrite {
            realm.add(calibration)
        }
        let reading = GlucoseReading.create(filtered: 100.0, unfiltered: 100.0, rssi: 0.0)
        XCTAssertNotNil(reading?.calibration)
    }
    
    func testFetchingWithDate() {
        XCTAssertNil(GlucoseReading.reading(for: Date()))
        
        let reading1 = GlucoseReading()
        reading1.setValue(Date(timeIntervalSince1970: 0.0), forKey: "date")
        reading1.setValue(1.0, forKey: "a")
        reading1.generateID()
        realm.safeWrite {
            realm.add(reading1)
        }
        
        XCTAssertNotNil(GlucoseReading.reading(for: Date(timeIntervalSince1970: 0.0)))
        XCTAssertNotNil(GlucoseReading.reading(for: Date(timeIntervalSince1970: .secondsPerMinute * 15.0 - 1.0)))
        XCTAssertNil(GlucoseReading.reading(for: Date(timeIntervalSince1970: .secondsPerMinute * 15.0 + 1.0)))
        
        let reading2 = GlucoseReading()
        reading2.setValue(Date(timeIntervalSince1970: 10.0), forKey: "date")
        reading2.setValue(2.0, forKey: "a")
        reading2.generateID()
        realm.safeWrite {
            realm.add(reading2)
        }
        
        let reading3 = GlucoseReading()
        reading3.generateID()
        realm.safeWrite {
            realm.add(reading3)
        }
        
        // Check we got reading1
        XCTAssert(GlucoseReading.reading(for: Date(timeIntervalSince1970: 0.0))!.a ~ 1.0)
        
        // Check we got reading1
        XCTAssert(GlucoseReading.reading(for: Date(timeIntervalSince1970: 4.99))!.a ~ 1.0)
        
        // Check we got reading2
        XCTAssert(GlucoseReading.reading(for: Date(timeIntervalSince1970: 5.0001))!.a ~ 2.0)
    }
    
    func testEstimatedRawGlucoseLevel() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "0"
        )
        CGMDevice.current.updateSensorIsStarted(true)
        
        XCTAssert(GlucoseReading.estimatedRawGlucoseLevel(date: Date()) ~ 160.0)
        
        let reading = GlucoseReading()
        reading.setValue(2.0, forKey: "ra")
        reading.setValue(3.0, forKey: "rb")
        reading.setValue(4.0, forKey: "rc")
        reading.setValue(1.0, forKey: "rawValue")
        reading.setValue(1.0, forKey: "calculatedValue")
        reading.setValue(Date(), forKey: "date")
        realm.safeWrite {
            realm.add(reading)
        }
        
        XCTAssert(GlucoseReading.estimatedRawGlucoseLevel(date: Date(timeIntervalSince1970: 5.0)) ~ 69.0)
    }
    
    func testUpdateCalculatedValue() {
        let reading = GlucoseReading()
        realm.safeWrite {
            realm.add(reading)
        }
        XCTAssert(reading.calculatedValue ~ 0.0)
        
        reading.updateCalculatedValue(2.0)
        XCTAssert(reading.calculatedValue ~ 2.0)
    }
    
    func testUpdateFilteredCalculatedValue() {
        let reading = GlucoseReading()
        realm.safeWrite {
            realm.add(reading)
        }
        XCTAssert(reading.filteredCalculatedValue ~ 0.0)
        
        reading.updateFilteredCalculatedValue(2.0)
        XCTAssert(reading.filteredCalculatedValue ~ 2.0)
    }
    
    func testUpdateIsCalibrated() {
        let reading = GlucoseReading()
        realm.safeWrite {
            realm.add(reading)
        }
        XCTAssertFalse(reading.isCalibrated)
        
        reading.updateIsCalibrated(true)
        XCTAssert(reading.isCalibrated)
    }
    
    func testFindingNewCurve() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "0"
        )
        CGMDevice.current.updateSensorIsStarted(true)
        
        let reading1 = GlucoseReading()
        reading1.setValue(Date(timeIntervalSince1970: 2.0), forKey: "date")
        reading1.setValue(22.0, forKey: "calculatedValue")
        reading1.setValue(22.0, forKey: "rawValue")
        reading1.generateID()
        
        realm.safeWrite {
            realm.add(reading1)
        }

        reading1.findNewCurve()
        XCTAssert(reading1.a ~ 0.0)
        XCTAssert(reading1.b ~ 0.0)
        XCTAssert(reading1.c ~ 22.0)
        
        let reading2 = GlucoseReading()
        reading2.setValue(Date(timeIntervalSince1970: 3.0), forKey: "date")
        reading2.setValue(33.0, forKey: "calculatedValue")
        reading2.setValue(33.0, forKey: "rawValue")
        reading2.generateID()
        
        realm.safeWrite {
            realm.add(reading2)
        }
        
        reading2.findNewCurve()
        XCTAssert(reading2.a ~ 0.0)
        XCTAssert(reading2.b ~ 11.0)
        XCTAssert(reading2.c ~ 22.0)
        
        let reading3 = GlucoseReading()
        reading3.setValue(Date(timeIntervalSince1970: 4.0), forKey: "date")
        reading3.setValue(44.0, forKey: "calculatedValue")
        reading3.setValue(44.0, forKey: "rawValue")
        reading3.generateID()
        
        realm.safeWrite {
            realm.add(reading3)
        }
        
        reading3.findNewCurve()
        XCTAssert(reading3.a ~ 0.0)
        XCTAssert(reading3.b ~ 11.0)
        XCTAssert(reading3.c ~ 0.0)
    }
    
    func testFindingNewRawCurve() {
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "0"
        )
        CGMDevice.current.updateSensorIsStarted(true)
        
        let reading1 = GlucoseReading()
        reading1.setValue(Date(timeIntervalSince1970: 2.0), forKey: "date")
        reading1.setValue(22.0, forKey: "ageAdjustedRawValue")
        reading1.setValue(22.0, forKey: "calculatedValue")
        reading1.setValue(22.0, forKey: "rawValue")
        reading1.generateID()
        
        realm.safeWrite {
            realm.add(reading1)
        }
        
        reading1.findNewRawCurve()
        XCTAssert(reading1.ra ~ 0.0)
        XCTAssert(reading1.rb ~ 0.0)
        XCTAssert(reading1.rc ~ 22.0)
        
        let reading2 = GlucoseReading()
        reading2.setValue(Date(timeIntervalSince1970: 3.0), forKey: "date")
        reading2.setValue(33.0, forKey: "ageAdjustedRawValue")
        reading2.setValue(33.0, forKey: "calculatedValue")
        reading2.setValue(33.0, forKey: "rawValue")
        reading2.generateID()
        
        realm.safeWrite {
            realm.add(reading2)
        }
        
        reading2.findNewRawCurve()
        XCTAssert(reading2.ra ~ 0.0)
        XCTAssert(reading2.rb ~ 11.0)
        XCTAssert(reading2.rc ~ 22.0)
        
        let reading3 = GlucoseReading()
        reading3.setValue(Date(timeIntervalSince1970: 4.0), forKey: "date")
        reading3.setValue(44.0, forKey: "ageAdjustedRawValue")
        reading3.setValue(44.0, forKey: "calculatedValue")
        reading3.setValue(44.0, forKey: "rawValue")
        reading3.generateID()
        
        realm.safeWrite {
            realm.add(reading3)
        }
        
        reading3.findNewRawCurve()
        XCTAssert(reading3.ra ~ 0.0)
        XCTAssert(reading3.rb ~ 11.0)
        XCTAssert(reading3.rc ~ 0.0)
    }
    
    func testUpdateCalibration() {
        let reading = GlucoseReading()
        realm.safeWrite {
            realm.add(reading)
        }
        XCTAssertNil(reading.calibration)
        
        reading.updateCalibration(Calibration())
        XCTAssertNotNil(reading.calibration)
        
        reading.updateCalibration(nil)
        XCTAssertNil(reading.calibration)
    }
    
    func testCalculateSlope() {
        let reading1 = GlucoseReading()
        let reading2 = GlucoseReading()
        
        XCTAssert(reading1.calculateSlope(lastReading: reading2) ~ 0.0)
        
        reading1.setValue(Date(timeIntervalSince1970: 5.0), forKey: "date")
        reading1.setValue(10.0, forKey: "calculatedValue")
        
        XCTAssert(reading1.calculateSlope(lastReading: reading2) ~ 0.0)
        
        reading2.setValue(Date(timeIntervalSince1970: 5.0), forKey: "date")
        reading2.setValue(15.0, forKey: "calculatedValue")
        
        XCTAssert(reading1.calculateSlope(lastReading: reading2) ~ 0.0)
        
        reading1.setValue(15.0, forKey: "calculatedValue")
        reading2.setValue(Date(timeIntervalSince1970: 500.0), forKey: "date")
        XCTAssert(reading1.calculateSlope(lastReading: reading2) ~ 0.0)
        
        reading1.setValue(10.0, forKey: "calculatedValue")
        
        XCTAssert(reading1.calculateSlope(lastReading: reading2) ~ 0.01010101010101)
    }
    
    func testUpdateCalculatedValueToWithinMinMax() {
        let reading = GlucoseReading()
        
        reading.setValue(9.0, forKey: "calculatedValue")
        reading.updateCalculatedValueToWithinMinMax()
        XCTAssert(reading.calculatedValue ~ -1.0)
        XCTAssert(reading.hideSlope)
        
        reading.setValue(10.0, forKey: "calculatedValue")
        reading.updateCalculatedValueToWithinMinMax()
        XCTAssert(reading.calculatedValue ~ 39.0)
        XCTAssertFalse(reading.hideSlope)
        
        reading.setValue(40.0, forKey: "calculatedValue")
        reading.updateCalculatedValueToWithinMinMax()
        XCTAssert(reading.calculatedValue ~ 40.0)
        XCTAssertFalse(reading.hideSlope)
        
        reading.setValue(400.0, forKey: "calculatedValue")
        reading.updateCalculatedValueToWithinMinMax()
        XCTAssert(reading.calculatedValue ~ 400.0)
        XCTAssertFalse(reading.hideSlope)
        
        reading.setValue(401.0, forKey: "calculatedValue")
        reading.updateCalculatedValueToWithinMinMax()
        XCTAssert(reading.calculatedValue ~ 400.0)
        XCTAssertFalse(reading.hideSlope)
    }
    
    func testActiveSlope() {
        let reading = GlucoseReading()
        let date = Date()
        XCTAssert(reading.activeSlope() ~ 0.0)
        
        reading.setValue(0.0, forKey: "a")
        reading.setValue(0.0, forKey: "b")
        XCTAssert(reading.activeSlope() ~ 0.0)
    
        reading.setValue(1.0 / date.timeIntervalSince1970, forKey: "a")
        reading.setValue(1.0, forKey: "b")
        XCTAssert(reading.activeSlope(date: date) ~ 3.0)
        
        reading.setValue(1.0 / date.timeIntervalSince1970, forKey: "a")
        reading.setValue(0.0, forKey: "b")
        XCTAssert(reading.activeSlope(date: date) ~ 2.0)
        
        reading.setValue(0.0, forKey: "a")
        reading.setValue(1.0, forKey: "b")
        XCTAssert(reading.activeSlope() ~ 1.0)
    }
    
    func testClearOldReadings() {
        let now = Date()
        let readingsPerDay = Int(TimeInterval.secondsPerDay / Constants.dexcomPeriod)
        
        CGMDevice.current.updateMetadata(
            ofType: .sensorAge,
            value: "\((now - .secondsPerDay).timeIntervalSince1970)"
        )
        CGMDevice.current.updateSensorIsStarted(true)
        
        for index in 0..<readingsPerDay {
            let filtered = 100.0 + Double(index) * 10.0
            let unfiltered = filtered * 1000.0 - 5000.0
            let date = now - TimeInterval(index) * .secondsPerMinute * 5.0 - 1.0
            GlucoseReading.create(filtered: filtered, unfiltered: unfiltered, rssi: 0.0, date: date)
        }
        
        var allGrossReadings = GlucoseReading.allMaster()
        var allLightReadings = LightGlucoseReading.allMaster
        
        XCTAssertTrue(allGrossReadings.count == 288)
        XCTAssertTrue(allLightReadings.isEmpty)
        
        for reading in allGrossReadings {
            realm.safeWrite {
                guard var date = reading.date else { return }
                date -= TimeInterval(.secondsPerMinute) * 5.0
                reading.setValue(date, forKey: "date")
            }
        }
        
        for reading in allLightReadings {
            realm.safeWrite {
                guard var date = reading.date else { return }
                date -= TimeInterval(.secondsPerMinute) * 5.0
                reading.setValue(date, forKey: "date")
            }
        }
        
        let filtered = 100.0 + Double(readingsPerDay) * 10.0
        let unfiltered = filtered * 1000.0 - 5000.0
        let date = now
        GlucoseReading.create(filtered: filtered, unfiltered: unfiltered, rssi: 0.0, date: date)
        
        allGrossReadings = GlucoseReading.allMaster()
        allLightReadings = LightGlucoseReading.allMaster
        
        XCTAssertTrue(allGrossReadings.count == 288)
        XCTAssertTrue(allLightReadings.count == 1)
    }
}

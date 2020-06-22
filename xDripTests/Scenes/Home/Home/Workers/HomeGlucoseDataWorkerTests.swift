//
//  HomeGlucoseDataWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
import RealmSwift
@testable import xDrip

final class HomeGlucoseDataWorkerTests: XCTestCase {    
    let sut = HomeGlucoseDataWorker()
    var calledDataHandler = false
    
    override func setUp() {
        super.setUp()
        
        sut.glucoseDataHandler = {
            self.calledDataHandler = true
        }
    }
    
    func testCallback() {
        // When
        CGMDevice.current.updateMetadata(ofType: .sensorAge, value: "\(Date().timeIntervalSince1970)")
        CGMDevice.current.updateSensorIsStarted(true)
        CGMController.shared.serviceDidReceiveGlucoseReading(raw: 0.0, filtered: 0.0)
        
        // Then
        XCTAssertTrue(calledDataHandler)
    }
    
    func testFetchLastGlucoseReading() {
        // Given
        let reading = GlucoseReading()
        reading.setValue(Date(), forKey: "date")
        reading.setValue(0.0, forKey: "filteredCalculatedValue")
        reading.generateID()
        // When
        User.current.settings.updateDeviceMode(.default)
        Realm.shared.safeWrite {
            Realm.shared.add(reading)
        }
        // Then
        XCTAssertNil(sut.fetchLastGlucoseReading())
        
        // Given
        let reading1 = GlucoseReading()
        reading1.setValue(Date() - .secondsPerDay, forKey: "date")
        reading1.setValue(0.1, forKey: "filteredCalculatedValue")
        reading1.generateID()
        // When
        User.current.settings.updateDeviceMode(.default)
        Realm.shared.safeWrite {
            Realm.shared.add(reading1)
        }
        // Then
        XCTAssertNil(sut.fetchLastGlucoseReading())
        
        // Given
        let reading2 = GlucoseReading()
        reading2.setValue(Date(), forKey: "date")
        reading2.setValue(0.1, forKey: "filteredCalculatedValue")
        reading2.setValue(UserDeviceMode.follower.rawValue, forKey: "rawDeviceMode")
        reading2.generateID()
        // When
        User.current.settings.updateDeviceMode(.follower)
        Realm.shared.safeWrite {
            Realm.shared.add(reading2)
        }
        // Then
        XCTAssertNotNil(sut.fetchLastGlucoseReading())
    }
}

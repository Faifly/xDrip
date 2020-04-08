//
//  InitialSetupDexcomG6SensorAgeWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupDexcomG6SensorAgeWorkerTests: XCTestCase {
    
    let sut = InitialSetupDexcomG6SensorAgeWorker()
    
    func testValidate() {
        let date = Date()
        
        XCTAssertTrue(sut.validateSensorAge(date))
    }
    
    func testSave() {
        let date = Date()
        
        // When
        sut.saveSensorAge(date)
        
        // Then
        let optMetadata = CGMDevice.current.metadata(ofType: .sensorAge)
        
        guard let metadata = optMetadata else {
            XCTFail("Sensor age didn't save")
            return
        }
        
        XCTAssertEqual("\(date.timeIntervalSince1970)", metadata.value)
    }
}

//
//  HomeGlucoseDataWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
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
        CGMController.shared.serviceDidReceiveGlucoseReading(raw: 0.0, filtered: 0.0)
        
        // Then
        XCTAssertTrue(calledDataHandler)
    }
}

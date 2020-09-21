//
//  TrainingIntensityTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class TrainingIntensityTests: XCTestCase {
    func testDefaultValue() {
        XCTAssertTrue(TrainingIntensity.default == .normal)
    }
    
    func testInit() {
        let intensity = TrainingIntensity(paramValue: "low")
        XCTAssertTrue(intensity == .low)
        
        let intensity1 = TrainingIntensity(paramValue: "moderate")
        XCTAssertTrue(intensity1 == .normal)
        
        let intensity2 = TrainingIntensity(paramValue: "high")
        XCTAssertTrue(intensity2 == .high)
        
        let intensity3 = TrainingIntensity(paramValue: "12345")
        XCTAssertTrue(intensity3 == .default)
    }
    
    func testParamValue() {
        let intensity = TrainingIntensity.low
        XCTAssertTrue(intensity.paramValue == "low")
        
        let intensity1 = TrainingIntensity.normal
        XCTAssertTrue(intensity1.paramValue == "moderate")
        
        let intensity2 = TrainingIntensity.high
        XCTAssertTrue(intensity2.paramValue == "high")
    }
}

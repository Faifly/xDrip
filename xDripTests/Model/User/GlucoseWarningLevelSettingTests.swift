//
//  GlucoseWarningLevelSettingTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class GlucoseWarningLevelSettingTests: XCTestCase {
    func testInit() {
        let obj1 = GlucoseWarningLevelSetting(level: .high, value: 1.1)
        XCTAssertTrue(obj1.warningLevel == .high)
        XCTAssertTrue(obj1.value ~ 1.1)
        
        let obj2 = GlucoseWarningLevelSetting(level: .urgentLow, value: 2.2)
        XCTAssertTrue(obj2.warningLevel == .urgentLow)
        XCTAssertTrue(obj2.value ~ 2.2)
    }
    
    func testWarningLevel() {
        let obj = GlucoseWarningLevelSetting(level: .urgentHigh, value: 1.1)
        XCTAssertTrue(obj.warningLevel == .urgentHigh)
        
        obj.setValue(-1, forKey: "rawWarningLevel")
        XCTAssertTrue(obj.warningLevel == .low)
    }
    
    func testValue() {
        let obj = GlucoseWarningLevelSetting(level: .urgentLow, value: 1.1)
        XCTAssertTrue(obj.value ~ 1.1)
        
        obj.updateValue(2.2)
        XCTAssertTrue(obj.value ~ 2.2)
    }
}

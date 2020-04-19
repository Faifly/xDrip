//
//  GlucoseWarningLevelTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class GlucoseWarningLevelTests: XCTestCase {
    func testDefaultValues() {
        XCTAssertTrue(abs(GlucoseWarningLevel.urgentLow.defaultValue - 50.0) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseWarningLevel.low.defaultValue - 70.0) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseWarningLevel.high.defaultValue - 130.0) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseWarningLevel.urgentHigh.defaultValue - 170.0) <= .ulpOfOne)
    }
}

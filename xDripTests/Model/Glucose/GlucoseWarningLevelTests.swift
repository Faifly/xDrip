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
        XCTAssertTrue(abs(GlucoseWarningLevel.urgentLow.defaultValue - 3.5) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseWarningLevel.low.defaultValue - 4.2) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseWarningLevel.high.defaultValue - 9.5) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseWarningLevel.urgentHigh.defaultValue - 11.0) <= .ulpOfOne)
    }
}

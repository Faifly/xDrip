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
        XCTAssertTrue(GlucoseWarningLevel.urgentLow.defaultValue ~ 55.0)
        XCTAssertTrue(GlucoseWarningLevel.low.defaultValue ~ 70.0)
        XCTAssertTrue(GlucoseWarningLevel.high.defaultValue ~ 170.0)
        XCTAssertTrue(GlucoseWarningLevel.urgentHigh.defaultValue ~ 200.0)
    }
}

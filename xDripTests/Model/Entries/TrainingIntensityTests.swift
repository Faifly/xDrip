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
}

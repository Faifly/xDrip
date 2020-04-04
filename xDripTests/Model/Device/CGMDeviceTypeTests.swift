//
//  CGMDeviceTypeTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class CGMDeviceTypeTests: XCTestCase {
    func testEnum() {
        XCTAssertTrue(CGMDeviceType.dexcomG6.rawValue == 0)
    }
}

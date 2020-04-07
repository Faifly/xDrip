//
//  UserDeviceModeTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class UserDeviceModeTests: XCTestCase {
    func testDefaultValue() {
        XCTAssertTrue(UserDeviceMode.default == .main)
    }
}

//
//  UIStoryboard+Content_Tests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class UIStoryboard_Content_Tests: XCTestCase {
    func testStoryboards() {
        XCTAssert(UIStoryboard.Storyboard.root.rawValue == "Root")
        _ = UIStoryboard(board: .root)
        XCTFail()
    }
}

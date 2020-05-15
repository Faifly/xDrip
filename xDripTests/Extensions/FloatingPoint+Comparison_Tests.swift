//
//  FloatingPoint+Comparison_Tests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 09.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class FloatingPoint_Comparison_Tests: XCTestCase {
    func testDoubleComparisons() {
        XCTAssertTrue(0.0 ~ 0.0)
        XCTAssertTrue(0.0 ~~ 0.0)
        XCTAssertTrue(1.0 ~ 1.0)
        XCTAssertTrue(1.0 ~~ 1.0)
        
        XCTAssertFalse(1.0 ~ 0.0)
        XCTAssertFalse(1.0 ~~ 0.0)
        XCTAssertFalse(1.0 ~ 0.0001)
        XCTAssertFalse(2.0 ~~ 0.0001)
        
        XCTAssertTrue(1.0 ~ 1.0000000000001)
        XCTAssertTrue(1.0 ~~ 1.9)
    }
    
    func testCGFloatComparisons() {
        XCTAssertTrue(0.0 as CGFloat ~ 0.0 as CGFloat)
        XCTAssertTrue(0.0 as CGFloat ~~ 0.0 as CGFloat)
        XCTAssertTrue(1.0 as CGFloat ~ 1.0 as CGFloat)
        XCTAssertTrue(1.0 as CGFloat ~~ 1.0 as CGFloat)
        
        XCTAssertFalse(1.0 as CGFloat ~ 0.0 as CGFloat)
        XCTAssertFalse(1.0 as CGFloat ~~ 0.0 as CGFloat)
        XCTAssertFalse(1.0 as CGFloat ~ 0.0001 as CGFloat)
        XCTAssertFalse(2.0 as CGFloat ~~ 0.0001 as CGFloat)
        
        XCTAssertTrue(1.0 as CGFloat ~ 1.0000000000001 as CGFloat)
        XCTAssertTrue(1.0 as CGFloat ~~ 1.9 as CGFloat)
    }
}

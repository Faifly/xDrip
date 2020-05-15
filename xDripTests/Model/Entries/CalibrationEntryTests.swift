//
//  CalibrationEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class CalibrationEntryTests: AbstractRealmTest {
    func testInit() {
        let date = Date(timeIntervalSince1970: 3.0)
        let entry = CalibrationEntry(firstValue: 1.1, secondValue: 2.2, date: date)
        
        XCTAssertTrue(entry.firstValue ~ 1.1)
        XCTAssertTrue(entry.secondValue ~ 2.2)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 3.0)
    }
    
    func testUpdate() {
        let entry = CalibrationEntry(firstValue: 1.1, secondValue: 2.2, date: Date())
        
        let date = Date(timeIntervalSince1970: 4.0)
        entry.update(firstValue: 3.3, secondValue: 5.5, date: date)
        
        XCTAssertTrue(entry.firstValue ~ 3.3)
        XCTAssertTrue(entry.secondValue ~ 5.5)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 4.0)
    }
}

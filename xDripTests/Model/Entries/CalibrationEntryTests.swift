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
        
        XCTAssertTrue(abs(entry.firstValue - 1.1) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.secondValue - 2.2) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 3.0) <= .ulpOfOne)
    }
    
    func testUpdate() {
        let entry = CalibrationEntry(firstValue: 1.1, secondValue: 2.2, date: Date())
        
        let date = Date(timeIntervalSince1970: 4.0)
        entry.update(firstValue: 3.3, secondValue: 5.5, date: date)
        
        XCTAssertTrue(abs(entry.firstValue - 3.3) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.secondValue - 5.5) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 4.0) <= .ulpOfOne)
    }
}

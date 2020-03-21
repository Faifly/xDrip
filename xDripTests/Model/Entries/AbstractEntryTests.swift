//
//  AbstractEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class AbstractEntryTests: XCTestCase {
    func testDate() {
        let entry = AbstractEntry()
        XCTAssertNil(entry.date)
        
        let date = Date(timeIntervalSince1970: 22.0)
        entry.updateDate(date)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 22.0) <= .ulpOfOne)
    }
    
    func testInit() {
        let date = Date(timeIntervalSince1970: 9.0)
        let entry = AbstractEntry(date: date)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 9.0) <= .ulpOfOne)
    }
}

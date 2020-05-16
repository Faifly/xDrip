//
//  BolusEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class BolusEntryTests: AbstractRealmTest {
    func testInit() {
        let date = Date(timeIntervalSince1970: 2.0)
        let entry = BolusEntry(amount: 1.1, date: date)
        
        XCTAssertTrue(entry.amount ~ 1.1)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 2.0)
    }
    
    func testUpdate() {
        let entry = BolusEntry(amount: 1.1, date: Date())
        
        let date = Date(timeIntervalSince1970: 3.0)
        entry.update(amount: 2.2, date: date)
        
        XCTAssertTrue(entry.amount ~ 2.2)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 3.0)
    }
}

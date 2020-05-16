//
//  CarbEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class CarbEntryTests: AbstractRealmTest {
    func testInit() {
        let date = Date(timeIntervalSince1970: 5.0)
        let entry = CarbEntry(amount: 1.1, foodType: "2.2", assimilationDuration: 3.3, date: date)
        
        XCTAssertTrue(entry.amount ~ 1.1)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(entry.assimilationDuration ~ 3.3)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 5.0)
    }
    
    func testUpdate() {
        let date = Date(timeIntervalSince1970: 6.0)
        let entry = CarbEntry(amount: 1.1, foodType: "1.1", assimilationDuration: 1.1, date: Date())
        entry.update(amount: 2.2, foodType: "2.2", assimilationDuration: 4.4, date: date)
        
        XCTAssertTrue(entry.amount ~ 2.2)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(entry.assimilationDuration ~ 4.4)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 6.0)
    }
}

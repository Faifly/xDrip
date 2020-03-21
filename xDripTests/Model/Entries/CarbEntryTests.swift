//
//  CarbEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class CarbEntryTests: AbstractRealmTest {
    func testInit() {
        let date = Date(timeIntervalSince1970: 5.0)
        let entry = CarbEntry(amount: 1.1, foodType: "2.2", assimilationDuration: 3.3, date: date)
        
        XCTAssertTrue(abs(entry.amount - 1.1) <= .ulpOfOne)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(abs(entry.assimilationDuration - 3.3) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 5.0) <= .ulpOfOne)
    }
    
    func testUpdate() {
        let date = Date(timeIntervalSince1970: 6.0)
        let entry = CarbEntry(amount: 1.1, foodType: "1.1", assimilationDuration: 1.1, date: Date())
        entry.update(amount: 2.2, foodType: "2.2", assimilationDuration: 4.4, date: date)
        
        XCTAssertTrue(abs(entry.amount - 2.2) <= .ulpOfOne)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(abs(entry.assimilationDuration - 4.4) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 6.0) <= .ulpOfOne)
    }
}

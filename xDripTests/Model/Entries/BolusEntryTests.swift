//
//  BolusEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BolusEntryTests: AbstractRealmTest {
    func testInit() {
        let date = Date(timeIntervalSince1970: 2.0)
        let entry = BolusEntry(amount: 1.1, date: date)
        
        XCTAssertTrue(abs(entry.amount - 1.1) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 2.0) <= .ulpOfOne)
    }
    
    func testUpdate() {
        let entry = BolusEntry(amount: 1.1, date: Date())
        
        let date = Date(timeIntervalSince1970: 3.0)
        entry.update(amount: 2.2, date: date)
        
        XCTAssertTrue(abs(entry.amount - 2.2) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 3.0) <= .ulpOfOne)
    }
}

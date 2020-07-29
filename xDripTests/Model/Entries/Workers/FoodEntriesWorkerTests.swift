//
//  FoodEntriesWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class FoodEntriesWorkerTests: AbstractRealmTest {
    func testAddingCarbEntry() {
        XCTAssertTrue(realm.objects(CarbEntry.self).isEmpty)
        
        let date = Date(timeIntervalSince1970: 6.0)
        let entry = CarbEntriesWorker.addCarbEntry(amount: 1.1, foodType: "2.2", date: date)
        XCTAssertTrue(entry.amount ~ 1.1)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(entry.assimilationDuration ~ 0.0)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 6.0)
        
        XCTAssertTrue(realm.objects(CarbEntry.self).count == 1)
    }
    
    func testFetchingCarbEntries() {
        XCTAssertTrue(realm.objects(CarbEntry.self).isEmpty)
        
        for index in 1...10 {
            let date = Date(timeIntervalSince1970: 1000.0 - Double(index) * 10.0)
            let entry = CarbEntry(amount: 1.0, foodType: "\(index)", date: date)
            realm.safeWrite {
                realm.add(entry)
            }
        }
        
        let entries = CarbEntriesWorker.fetchAllCarbEntries()
        XCTAssertTrue(entries.count == 10)
        XCTAssertTrue(entries[0].foodType == "10")
        XCTAssertTrue(entries[9].foodType == "1")
    }
    
    func testAddingBolusEntry() {
        XCTAssertTrue(realm.objects(InsulinEntry.self).isEmpty)
        
        let date = Date(timeIntervalSince1970: 7.0)
        let entry = InsulinEntriesWorker.addBolusEntry(amount: 2.2, date: date)
        XCTAssertTrue(entry.amount ~ 2.2)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 7.0)
        
        XCTAssertTrue(realm.objects(InsulinEntry.self).count == 1)
    }
    
    func testFetchingBolusEntries() {
        XCTAssertTrue(realm.objects(InsulinEntry.self).isEmpty)
        
        for index in 1...10 {
            let date = Date(timeIntervalSince1970: 1000.0 - Double(index) * 10.0)
            let entry = InsulinEntry(amount: Double(index), date: date, type: .bolus)
            realm.safeWrite {
                realm.add(entry)
            }
        }
        
        let entries = InsulinEntriesWorker.fetchAllBolusEntries()
        XCTAssertTrue(entries.count == 10)
        XCTAssertTrue(entries[0].amount ~ 10.0)
        XCTAssertTrue(entries[9].amount ~ 1.0)
    }
}

//
//  FoodEntriesWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class FoodEntriesWorkerTests: AbstractRealmTest {
    func testAddingCarbEntry() {
        XCTAssertTrue(realm.objects(CarbEntry.self).count == 0)
        
        let date = Date(timeIntervalSince1970: 6.0)
        let entry = FoodEntriesWorker.addCarbEntry(amount: 1.1, foodType: "2.2", assimilationDuration: 3.3, date: date)
        XCTAssertTrue(abs(entry.amount - 1.1) <= .ulpOfOne)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(abs(entry.assimilationDuration - 3.3) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 6.0) <= .ulpOfOne)
        
        XCTAssertTrue(realm.objects(CarbEntry.self).count == 1)
    }
    
    func testFetchingCarbEntries() {
        XCTAssertTrue(realm.objects(CarbEntry.self).count == 0)
        
        for i in 1...10 {
            let date = Date(timeIntervalSince1970: 1000.0 - Double(i) * 10.0)
            let entry = CarbEntry(amount: 1.0, foodType: "\(i)", assimilationDuration: 1.0, date: date)
            realm.safeWrite {
                realm.add(entry)
            }
        }
        
        let entries = FoodEntriesWorker.fetchAllCarbEntries()
        XCTAssertTrue(entries.count == 10)
        XCTAssertTrue(entries[0].foodType == "10")
        XCTAssertTrue(entries[9].foodType == "1")
    }
    
    func testAddingBolusEntry() {
        XCTAssertTrue(realm.objects(BolusEntry.self).count == 0)
        
        let date = Date(timeIntervalSince1970: 7.0)
        let entry = FoodEntriesWorker.addBolusEntry(amount: 2.2, date: date)
        XCTAssertTrue(abs(entry.amount - 2.2) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 7.0) <= .ulpOfOne)
        
        XCTAssertTrue(realm.objects(BolusEntry.self).count == 1)
    }
    
    func testFetchingBolusEntries() {
        XCTAssertTrue(realm.objects(BolusEntry.self).count == 0)
        
        for i in 1...10 {
            let date = Date(timeIntervalSince1970: 1000.0 - Double(i) * 10.0)
            let entry = BolusEntry(amount: Double(i), date: date)
            realm.safeWrite {
                realm.add(entry)
            }
        }
        
        let entries = FoodEntriesWorker.fetchAllBolusEntries()
        XCTAssertTrue(entries.count == 10)
        XCTAssertTrue(abs(entries[0].amount - 10.0) <= .ulpOfOne)
        XCTAssertTrue(abs(entries[9].amount - 1.0) <= .ulpOfOne)
    }
}

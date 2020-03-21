//
//  AbstractEntriesWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class AbstractEntriesWorkerTests: AbstractRealmTest {
    func testAddingEntry() {
        XCTAssertTrue(realm.objects(CustomEntry.self).count == 0)
        
        let entry = CustomEntry()
        entry.customField = "123"
        let addedEntry = AbstractEntriesWorker.add(entry: entry)
        
        XCTAssertTrue(entry == addedEntry)
        XCTAssertTrue(realm.objects(CustomEntry.self).count == 1)
        XCTAssertTrue(realm.objects(CustomEntry.self).first!.customField == "123")
    }
    
    func testFetching() {
        XCTAssertTrue(realm.objects(CustomEntry.self).count == 0)
        
        for i in 1...10 {
            let date = Date(timeIntervalSince1970: 1000.0 - Double(i) * 10.0)
            let entry = CustomEntry(date: date)
            entry.customField = "\(i)"
            realm.safeWrite {
                realm.add(entry)
            }
        }
        
        let entries = AbstractEntriesWorker.fetchAllEntries(type: CustomEntry.self)
        XCTAssertTrue(entries.count == 10)
        XCTAssertTrue(entries[0].customField == "10")
        XCTAssertTrue(entries[9].customField == "1")
    }
    
    func testDeletingEntry() {
        XCTAssertTrue(realm.objects(CustomEntry.self).count == 0)
        
        let obj1 = CustomEntry()
        obj1.customField = "1"
        AbstractEntriesWorker.add(entry: obj1)
        
        let obj2 = CustomEntry()
        obj2.customField = "2"
        AbstractEntriesWorker.add(entry: obj2)
        
        XCTAssertTrue(realm.objects(CustomEntry.self).count == 2)
        
        AbstractEntriesWorker.deleteEntry(obj1)
        XCTAssertTrue(realm.objects(CustomEntry.self).count == 1)
        XCTAssertTrue(realm.objects(CustomEntry.self).first!.customField == "2")
        
        AbstractEntriesWorker.deleteEntry(obj2)
        XCTAssertTrue(realm.objects(CustomEntry.self).count == 0)
    }
}

final class CustomEntry: AbstractEntry {
    @objc dynamic var customField: String?
}

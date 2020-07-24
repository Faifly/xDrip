//
//  CalibrationEntriesWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class CalibrationEntriesWorkerTests: AbstractRealmTest {
    func testAddingEntry() {
        XCTAssertTrue(realm.objects(CalibrationEntry.self).isEmpty)
        
        let date = Date(timeIntervalSince1970: 7.0)
        let entry = CalibrationEntriesWorker.addCalibrationEntry(firstValue: 1.1, secondValue: 2.2, date: date)
        XCTAssertTrue(entry.firstValue ~ 1.1)
        XCTAssertTrue(entry.secondValue ~ 2.2)
        XCTAssertTrue(entry.entryDate!.timeIntervalSince1970 ~ 7.0)
        
        XCTAssertTrue(realm.objects(CalibrationEntry.self).count == 1)
    }
    
    func testFetchingEntries() {
        XCTAssertTrue(realm.objects(CalibrationEntry.self).isEmpty)
        
        for index in 1...10 {
            let date = Date(timeIntervalSince1970: 1000.0 - Double(index) * 10.0)
            let entry = CalibrationEntry(firstValue: Double(index), secondValue: 0.0, date: date)
            realm.safeWrite {
                realm.add(entry)
            }
        }
        
        let entries = CalibrationEntriesWorker.fetchAllEntries()
        XCTAssertTrue(entries.count == 10)
        XCTAssertTrue(entries[0].firstValue ~ 10.0)
        XCTAssertTrue(entries[9].firstValue ~ 1.0)
    }
}

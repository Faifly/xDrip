//
//  CalibrationEntriesWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class CalibrationEntriesWorkerTests: AbstractRealmTest {
    func testAddingEntry() {
        XCTAssertTrue(realm.objects(CalibrationEntry.self).count == 0)
        
        let date = Date(timeIntervalSince1970: 7.0)
        let entry = CalibrationEntriesWorker.addCalibrationEntry(firstValue: 1.1, secondValue: 2.2, date: date)
        XCTAssertTrue(abs(entry.firstValue - 1.1) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.secondValue - 2.2) <= .ulpOfOne)
        XCTAssertTrue(abs(entry.date!.timeIntervalSince1970.rounded() - 7.0) <= .ulpOfOne)
        
        XCTAssertTrue(realm.objects(CalibrationEntry.self).count == 1)
    }
    
    func testFetchingEntries() {
        XCTAssertTrue(realm.objects(CalibrationEntry.self).count == 0)
        
        for i in 1...10 {
            let date = Date(timeIntervalSince1970: 1000.0 - Double(i) * 10.0)
            let entry = CalibrationEntry(firstValue: Double(i), secondValue: 0.0, date: date)
            realm.safeWrite {
                realm.add(entry)
            }
        }
        
        let entries = CalibrationEntriesWorker.fetchAllEntries()
        XCTAssertTrue(entries.count == 10)
        XCTAssertTrue(abs(entries[0].firstValue - 10.0) <= .ulpOfOne)
        XCTAssertTrue(abs(entries[9].firstValue - 1.0) <= .ulpOfOne)
    }
}

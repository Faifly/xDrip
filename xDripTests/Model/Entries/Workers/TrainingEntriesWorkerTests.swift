//
//  TrainingEntriesWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class TrainingEntriesWorkerTests: AbstractRealmTest {
    func testAddingEntry() {
        XCTAssertTrue(realm.objects(TrainingEntry.self).isEmpty)
        
        let date = Date(timeIntervalSince1970: 7.0)
        let entry = TrainingEntriesWorker.addTraining(duration: 1.1, intensity: .high, date: date)
        XCTAssertTrue(entry.duration ~ 1.1)
        XCTAssertTrue(entry.intensity == .high)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 7.0)
        
        XCTAssertTrue(realm.objects(TrainingEntry.self).count == 1)
    }
    
    func testFetchingEntries() {
        XCTAssertTrue(realm.objects(TrainingEntry.self).isEmpty)
        
        for index in 1...10 {
            let date = Date(timeIntervalSince1970: 1000.0 - Double(index) * 10.0)
            let entry = TrainingEntry(duration: Double(index), intensity: .low, date: date)
            realm.safeWrite {
                realm.add(entry)
            }
        }
        
        let entries = TrainingEntriesWorker.fetchAllTrainings()
        XCTAssertTrue(entries.count == 10)
        XCTAssertTrue(entries[0].duration ~ 10.0)
        XCTAssertTrue(entries[9].duration ~ 1.0)
    }
}

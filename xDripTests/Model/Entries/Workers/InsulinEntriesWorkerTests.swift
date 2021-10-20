//
//  InsulinEntriesWorkerTests.swift
//  xDripTests
//
//  Created by Dmitry on 14.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InsulinEntriesWorkerTests: AbstractRealmTest {
    func testAddingBolusEntry() throws {
        XCTAssertTrue(realm.objects(InsulinEntry.self).isEmpty)
        
        let date = Date(timeIntervalSince1970: 7.0)
        let entry = InsulinEntriesWorker.addBolusEntry(amount: 2.2, date: date)
        XCTAssertTrue(entry.amount ~ 2.2)
        let entryDate = try XCTUnwrap(entry.date)
        XCTAssertTrue(entryDate.timeIntervalSince1970 ~~ 7.0)
        XCTAssertNotNil(entry.externalID)
        
        XCTAssertTrue(realm.objects(InsulinEntry.self).count == 1)
        
        let entry1 = InsulinEntriesWorker.addBolusEntry(amount: 1.0,
                                                        date: Date(),
                                                        externalID: "654321")
        
        XCTAssertTrue(entry1.externalID == "654321")
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
    
    func testDeleteBolusEntry() throws {
        let settings = try XCTUnwrap(User.current.settings.nightscoutSync)
        settings.updateIsEnabled(false)
        settings.updateUploadTreatments(false)
        let bolusEntry = InsulinEntry(amount: 1.9, date: Date(), type: .bolus)
        realm.safeWrite {
            realm.add(bolusEntry)
        }
        
        let entries = InsulinEntriesWorker.fetchAllBolusEntries()
        
        XCTAssertTrue(entries.count == 1)
        
        let entry = try XCTUnwrap(entries.first)
        
        InsulinEntriesWorker.deleteInsulinEntry(entry)
        
        XCTAssertTrue(InsulinEntriesWorker.fetchAllBolusEntries().isEmpty)
        
        settings.updateIsEnabled(true)
        settings.updateUploadTreatments(true)
        
        let bolusEntry1 = InsulinEntry(amount: 4.9, date: Date(), type: .bolus)
        realm.safeWrite {
            realm.add(bolusEntry1)
        }
        
        InsulinEntriesWorker.deleteInsulinEntry(bolusEntry1)
        
        XCTAssertTrue(InsulinEntriesWorker.fetchAllBolusEntries().count == 1)
        XCTAssertTrue(bolusEntry1.cloudUploadStatus == .waitingForDeletion)
    }
    
    func testDeleteEntryWithExternalID() throws {
        let externalID = "111"
        let carbEntry = InsulinEntry(amount: 7.9,
                                     date: Date(),
                                     type: .bolus,
                                     externalID: externalID)
        realm.safeWrite {
            realm.add(carbEntry)
        }
        
        let entries = InsulinEntriesWorker.fetchAllBolusEntries()
        
        XCTAssertTrue(entries.count == 1)
        
        let entry = try XCTUnwrap(entries.first)
        
        XCTAssertTrue(entry.externalID == externalID)
        
        InsulinEntriesWorker.deleteEntryWith(externalID: externalID)
        
        XCTAssertTrue(InsulinEntriesWorker.fetchAllBolusEntries().isEmpty)
    }
    
    func testMarkEntryAsUploaded() throws {
        InsulinEntriesWorker.addBolusEntry(amount: 1.5, date: Date())
        
        let entries = InsulinEntriesWorker.fetchAllBolusEntries()
        
        XCTAssertTrue(entries.count == 1)
        
        let entry = try XCTUnwrap(entries.first)
        
        XCTAssertTrue(entry.cloudUploadStatus == .notUploaded)
        
        let externalID = entry.externalID
        
        InsulinEntriesWorker.markEntryAsUploaded(externalID: externalID)
        
        XCTAssertTrue(entry.cloudUploadStatus == .uploaded)
    }
}

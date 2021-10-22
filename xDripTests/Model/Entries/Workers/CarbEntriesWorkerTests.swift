//
//  CarbEntriesWorkerTests.swift
//  xDripTests
//
//  Created by Dmitry on 14.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip
final class CarbEntriesWorkerTests: AbstractRealmTest {
    func testAddingCarbEntry() throws {
        XCTAssertTrue(realm.objects(CarbEntry.self).isEmpty)
        
        let date = Date(timeIntervalSince1970: 6.0)
        let entry = CarbEntriesWorker.addCarbEntry(amount: 1.1, foodType: "2.2", date: date)
        XCTAssertTrue(entry.amount ~ 1.1)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(entry.absorptionDuration ~ User.current.settings.carbsAbsorptionRate)
        let entryDate = try XCTUnwrap(entry.date)
        XCTAssertTrue(entryDate.timeIntervalSince1970 ~~ 6.0)
        XCTAssertNotNil(entry.externalID)
        XCTAssertTrue(realm.objects(CarbEntry.self).count == 1)
        
        let entry1 = CarbEntriesWorker.addCarbEntry(amount: 1.0,
                                                    foodType: "1.1",
                                                    date: Date(),
                                                    externalID: "123456")
        
        XCTAssertTrue(entry1.externalID == "123456")
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
    
    func testDeleteCarbsEntry() throws {
        let externalID = "123"
        let carbEntry = CarbEntry(amount: 1.9, foodType: "1.2", date: Date(), externalID: externalID)
        realm.safeWrite {
            realm.add(carbEntry)
        }
        
        let entries = CarbEntriesWorker.fetchAllCarbEntries()
        
        XCTAssertTrue(entries.count == 1)
        
        let entry = try XCTUnwrap(entries.first)
        
        CarbEntriesWorker.deleteCarbsEntry(entry)
        
        XCTAssertTrue(CarbEntriesWorker.fetchAllCarbEntries().count == 1)
        
        XCTAssertTrue(entry.cloudUploadStatus == .waitingForDeletion)
        
        let url = try XCTUnwrap(URL(string: "https://google.com"))
        
        NightscoutRequestCompleter.completeRequest(UploadRequest(request: URLRequest(url: url),
                                                                 itemIDs: [externalID],
                                                                 type: .deleteCarbs))
        
        DispatchQueue.main.async {
            XCTAssertTrue(CarbEntriesWorker.fetchAllCarbEntries().isEmpty)
        }
    }
    
    func testDeleteEntryWithExternalID() throws {
        let externalID = "111"
        let carbEntry = CarbEntry(amount: 7.9, foodType: "1.2", date: Date(), externalID: externalID)
        realm.safeWrite {
            realm.add(carbEntry)
        }
        
        let entries = CarbEntriesWorker.fetchAllCarbEntries()
        
        XCTAssertTrue(entries.count == 1)
        
        let entry = try XCTUnwrap(entries.first)
        
        XCTAssertTrue(entry.externalID == externalID)
        
        CarbEntriesWorker.deleteEntryWith(externalID: externalID)
        
        XCTAssertTrue(CarbEntriesWorker.fetchAllCarbEntries().isEmpty)
    }
    
    func testMarkEntryAsUploaded() throws {
        CarbEntriesWorker.addCarbEntry(amount: 1.7, foodType: "1.3", date: Date())
        
        let entries = CarbEntriesWorker.fetchAllCarbEntries()
        
        XCTAssertTrue(entries.count == 1)
        
        let entry = try XCTUnwrap(entries.first)
        
        XCTAssertTrue(entry.cloudUploadStatus == .notUploaded)
        
        let externalID = entry.externalID
        
        CarbEntriesWorker.markEntryAsUploaded(externalID: externalID)
        
        XCTAssertTrue(entry.cloudUploadStatus == .uploaded)
    }
}

//
//  EntriesListCarbsPersistenceWorkerTests.swift
//  xDripTests
//
//  Created by Dmitry on 14.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class EntriesListCarbsPersistenceWorkerTests: AbstractRealmTest {
    func testFetchEntries() {
        let carbEntry = CarbEntry(amount: 7.9, foodType: "1.2", date: Date())
        realm.safeWrite {
            realm.add(carbEntry)
        }
        let entries = EntriesListCarbsPersistenceWorker().fetchEntries()
        XCTAssertTrue(!entries.isEmpty)
        
        carbEntry.updateCloudUploadStatus(.waitingForDeletion)
        
        let entries1 = EntriesListCarbsPersistenceWorker().fetchEntries()
        XCTAssertTrue(entries1.isEmpty)
    }
}

//
//  BasalChartDataWorkerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 23.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BasalChartDataWorkerTests: AbstractRealmTest {
    func testFetchBasalData() throws {
        let minimumDate = Date() - .secondsPerDay
        
        InsulinEntriesWorker.addBasalEntry(amount: 12.0, date: minimumDate + .secondsPerHour)
        InsulinEntriesWorker.addBasalEntry(amount: 24.0, date: minimumDate - .secondsPerHour)
        InsulinEntriesWorker.addBolusEntry(amount: 12.0, date: minimumDate + .secondsPerHour)
        
        let basals = BasalChartDataWorker.fetchAllBasalDataForCurrentMode()
        
        XCTAssert(basals.count == 2)
        
        let entry = try XCTUnwrap(basals.first)
        
        entry.updateCloudUploadStatus(.waitingForDeletion)
        
        XCTAssert(!entry.isValid)
        
        let basals1 = BasalChartDataWorker.fetchAllBasalDataForCurrentMode()
               
        XCTAssert(basals1.count == 1)
    }
    
    func testFetchBasalDataForDate() throws {
        InsulinEntriesWorker.addBasalEntry(amount: 12.0, date: Date())
        let basals = BasalChartDataWorker.fetchAllBasalDataForCurrentMode()
        
        let entry = try XCTUnwrap(basals.first)
        XCTAssert(entry.isValid)
        
        entry.updateCloudUploadStatus(.waitingForDeletion)
        XCTAssert(!entry.isValid)
        
        let basals1 = BasalChartDataWorker.fetchAllBasalDataForCurrentMode()
                     
        XCTAssert(basals1.isEmpty)
    }
}

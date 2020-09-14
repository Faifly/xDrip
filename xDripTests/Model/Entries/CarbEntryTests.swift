//
//  CarbEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class CarbEntryTests: AbstractRealmTest {
    func testInit() throws {
        let settings = try XCTUnwrap(User.current.settings.nightscoutSync)
        let date = Date(timeIntervalSince1970: 5.0)
        settings.updateIsEnabled(true)
        settings.updateUploadTreatments(true)
        let entry = CarbEntry(amount: 1.1, foodType: "2.2", date: date)
        
        XCTAssertTrue(entry.amount ~ 1.1)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(entry.assimilationDuration ~ 0)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 5.0)
        XCTAssertTrue(entry.cloudUploadStatus == .notUploaded)
        
        settings.updateUploadTreatments(false)
        let entry1 = CarbEntry(amount: 5.1, foodType: "2.2", date: Date())
        XCTAssertTrue(entry1.cloudUploadStatus == .notApplicable)
        
        settings.updateUploadTreatments(true)
        let entry2 = CarbEntry(amount: 6.1, foodType: "2.2", date: Date(), externalID: "12345")
        XCTAssertTrue(entry2.cloudUploadStatus == .uploaded)
    }
    
    func testUpdate() {
        let date = Date(timeIntervalSince1970: 6.0)
        let entry = CarbEntry(amount: 1.1, foodType: "1.1", date: Date())
        entry.update(amount: 2.2, foodType: "2.2", date: date)
        
        XCTAssertTrue(entry.amount ~ 2.2)
        XCTAssertTrue(entry.foodType == "2.2")
        XCTAssertTrue(entry.assimilationDuration ~ 0)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 6.0)
        
        let entry1 = CarbEntry(amount: 5.1, foodType: "1.1", date: Date())
        entry1.updateCloudUploadStatus(.uploaded)
        entry1.update(amount: 2.3, foodType: "2.2", date: date)
        XCTAssertTrue(entry1.cloudUploadStatus == .modified)
    }
}

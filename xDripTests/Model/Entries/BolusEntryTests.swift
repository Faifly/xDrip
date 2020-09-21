//
//  BolusEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class BolusEntryTests: AbstractRealmTest {
    func testInit() throws {
        let settings = try XCTUnwrap(User.current.settings.nightscoutSync)
        settings.updateIsEnabled(true)
        settings.updateUploadTreatments(true)
        let date = Date(timeIntervalSince1970: 2.0)
        let entry = InsulinEntry(amount: 1.1, date: date, type: .bolus)
        
        XCTAssertTrue(entry.amount ~ 1.1)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 2.0)
        
        XCTAssertTrue(entry.cloudUploadStatus == .notUploaded)
        
        settings.updateUploadTreatments(false)
        let entry1 = InsulinEntry(amount: 5.1, date: Date(), type: .bolus)
        XCTAssertTrue(entry1.cloudUploadStatus == .notApplicable)
        
        settings.updateUploadTreatments(true)
        let entry2 = InsulinEntry(amount: 6.1, date: Date(), type: .bolus, externalID: "12345")
        XCTAssertTrue(entry2.cloudUploadStatus == .uploaded)
    }
    
    func testUpdate() {
        let entry = InsulinEntry(amount: 1.1, date: Date(), type: .bolus)
        
        let date = Date(timeIntervalSince1970: 3.0)
        entry.update(amount: 2.2, date: date)
        
        XCTAssertTrue(entry.amount ~ 2.2)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 3.0)
        
        let entry1 = InsulinEntry(amount: 5.1, date: Date(), type: .bolus)
        entry1.updateCloudUploadStatus(.uploaded)
        entry1.update(amount: 2.3, date: date)
        XCTAssertTrue(entry1.cloudUploadStatus == .modified)
    }
}

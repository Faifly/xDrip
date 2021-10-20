//
//  AbstractEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class AbstractEntryTests: XCTestCase {
    func testDate() {
        let entry = AbstractEntry()
        XCTAssertNil(entry.date)
        
        let date = Date(timeIntervalSince1970: 22.0)
        entry.updateDate(date)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 22.0)
    }
    
    func testInit() {
        let date = Date(timeIntervalSince1970: 9.0)
        let entry = AbstractEntry(date: date)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 9.0)
        XCTAssertNotNil(entry.externalID)
        
        let entry1 = AbstractEntry(date: date, externalID: "externalID")
        XCTAssertTrue(entry1.externalID == "externalID")
    }
    
    func testUpdateCloudUploadAsatus() {
        let entry = AbstractEntry(date: Date())
        
        XCTAssertTrue(entry.cloudUploadStatus == .notUploaded)
        
        let cloudUploadStatus: CloudUploadStatus = .waitingForDeletion
        
        entry.updateCloudUploadStatus(cloudUploadStatus)
        
        XCTAssertTrue(entry.cloudUploadStatus == cloudUploadStatus)
        
        XCTAssertTrue(!entry.isValid)
    }
}

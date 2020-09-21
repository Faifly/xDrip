//
//  NightscoutServiceTests.swift
//  xDripTests
//
//  Created by Dmitry on 15.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable implicitly_unwrapped_optional

final class NightscoutServiceTests: XCTestCase {
    let sut = NightscoutService.shared
    var settings: NightscoutSyncSettings!
    override func setUp() {
        super.setUp()
        do { try initSettings() } catch { XCTFail("Couldn't init NightscoutSyncSettings") }
    }
    
    func initSettings() throws {
        settings = try XCTUnwrap(User.current.settings.nightscoutSync)
        settings.updateIsEnabled(true)
        settings.updateUploadTreatments(true)
        settings.updateBaseURL("baseURL")
        settings.updateAPISecret("apiSecret")
    }
    
    func testCarbsUpload() throws {
        let mirror = NightscoutServiceMirror(object: sut)
        
        let entry = CarbEntriesWorker.addCarbEntry(amount: 1.8, foodType: "1.4", date: Date())
        
        let externalID = entry.externalID
        
        let postResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .postCarbs
        })
        
        XCTAssertTrue(postResult)
        
        entry.updateCloudUploadStatus(.uploaded)
        
        entry.update(amount: 2.0, foodType: "2.0", date: Date())
        
        let modifyResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .modifyCarbs
        })
        
        XCTAssertTrue(modifyResult)
        
        CarbEntriesWorker.deleteCarbsEntry(entry)
        
        let deleteResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .deleteCarbs
        })
        
        XCTAssertTrue(deleteResult)
    }
    
    func testBolusUpload() throws {
        let mirror = NightscoutServiceMirror(object: sut)
        
        let entry = InsulinEntriesWorker.addBolusEntry(amount: 1.1, date: Date())
        
        let externalID = entry.externalID
        
        let postResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .postBolus
        })
        
        XCTAssertTrue(postResult)
        
        entry.updateCloudUploadStatus(.uploaded)
        
        entry.update(amount: 2.0, date: Date())
        
        let modifyResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .modifyBolus
        })
        
        XCTAssertTrue(modifyResult)
        
        InsulinEntriesWorker.deleteInsulinEntry(entry)
        
        let deleteResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .deleteBolus
        })
        
        XCTAssertTrue(deleteResult)
    }
    
    func testBasalUpload() throws {
        let mirror = NightscoutServiceMirror(object: sut)
        
        let entry = InsulinEntriesWorker.addBasalEntry(amount: 1.1, date: Date())
        
        let externalID = entry.externalID
        
        let postResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .postBasal
        })
        
        XCTAssertTrue(postResult)
        
        entry.updateCloudUploadStatus(.uploaded)
        
        entry.update(amount: 2.0, date: Date())
        
        let modifyResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .modifyBasal
        })
        
        XCTAssertTrue(modifyResult)
        
        InsulinEntriesWorker.deleteInsulinEntry(entry)
        
        let deleteResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .deleteBasal
        })
        
        XCTAssertTrue(deleteResult)
    }
    
    func testTrainigUpload() throws {
        let mirror = NightscoutServiceMirror(object: sut)
        
        let entry = TrainingEntriesWorker.addTraining(duration: 1.1, intensity: .high, date: Date())
        
        let externalID = entry.externalID
        
        let postResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .postTraining
        })
        
        XCTAssertTrue(postResult)
        
        entry.updateCloudUploadStatus(.uploaded)
        
        entry.update(duration: 2.0, intensity: .low, date: Date())
        
        let modifyResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .modifyTraining
        })
        
        XCTAssertTrue(modifyResult)
        
        TrainingEntriesWorker.deleteTrainingEntry(entry)
        
        let deleteResult = try XCTUnwrap(mirror.requestQueue).contains(where: {
            $0.itemID == externalID && $0.type == .deleteTraining
        })
        
        XCTAssertTrue(deleteResult)
    }
}

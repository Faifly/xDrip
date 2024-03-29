//
//  UploadRequestFactoryTests.swift
//  xDripTests
//
//  Created by Dmitry on 14.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class UploadRequestFactoryTests: XCTestCase {
    var sut: UploadRequestFactory?
    
    override func setUp() {
        super.setUp()
        sut = UploadRequestFactory()
    }
    
    func testCreateNotUploadedTreatmentRequest() throws {
        // Given
        let carbEntry = CarbEntry(amount: 1.0, foodType: "1.1", date: Date())
        let treatment = CTreatment(entry: carbEntry, treatmentType: .carbs)
        let settings = try XCTUnwrap(User.current.settings.nightscoutSync)
        settings.updateMasterBaseURL("baseURL")
        settings.updateMasterAPISecret("apiSecret")
        
        // When
        
        let uploadRequset = sut?.createNotUploadedTreatmentRequest(treatment, requestType: .postCarbs)
        let modifyRequset = sut?.createModifiedTreatmentRequest(treatment, requestType: .postCarbs)
        
        // Then
        XCTAssertTrue(uploadRequset == modifyRequset)
        let request = try XCTUnwrap(uploadRequset)
        XCTAssertTrue(request.request.url?.absoluteString == "baseURL/api/v1/treatments")
        XCTAssertTrue(request.request.httpMethod == "PUT")
        let fields = ["Content-Type": "application/json", "API-SECRET": "apiSecret".sha1]
        XCTAssertTrue(request.request.allHTTPHeaderFields == fields)
        let externalID = try XCTUnwrap(carbEntry.externalID)
        XCTAssertTrue(request.itemIDs.contains(externalID))
    }
    
    func testCreateDeleteTreatmentRequest() throws {
        // Given
        let uuid = "12345"
        let settings = try XCTUnwrap(User.current.settings.nightscoutSync)
        settings.updateMasterBaseURL("baseURL")
        settings.updateMasterAPISecret("apiSecret")
        
        // When
        let deleteRequset = sut?.createDeleteTreatmentRequest(uuid, requestType: .deleteCarbs)
        
        // Then
        
        XCTAssertTrue(deleteRequset?.request.url?.absoluteString == "baseURL/api/v1/treatments/\(uuid)")
        XCTAssertTrue(deleteRequset?.request.httpMethod == "DELETE")
        let fields = ["Content-Type": "application/json", "API-SECRET": "apiSecret".sha1]
        XCTAssertTrue(deleteRequset?.request.allHTTPHeaderFields == fields)
    }
    
    func testCreateFetchTreatmentsRequest() throws {
        // Given
        let settings = try XCTUnwrap(User.current.settings.nightscoutSync)
        settings.updateIsEnabled(true)
        settings.updateMasterBaseURL("baseURL")
        settings.updateMasterAPISecret("apiSecret")
        
        // When
        let getRequset = sut?.createFetchFollowerTreatmentsRequest()
        
        // Then
        XCTAssertTrue(getRequset?.url?.absoluteString == "baseURL/api/v1/treatments")
        XCTAssertTrue(getRequset?.httpMethod == "GET")
        let isFieldsEmpty = try XCTUnwrap(getRequset?.allHTTPHeaderFields?.isEmpty)
        XCTAssertTrue(isFieldsEmpty)
    }
}

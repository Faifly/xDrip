//
//  NightscoutCloudBackfillInteractorTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

final class NightscoutCloudBackfillInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: NightscoutCloudBackfillInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupNightscoutCloudBackfillInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupNightscoutCloudBackfillInteractor() {
        sut = NightscoutCloudBackfillInteractor()
    }
    
    // MARK: Test doubles
    
    final class NightscoutCloudBackfillPresentationLogicSpy: NightscoutCloudBackfillPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: NightscoutCloudBackfill.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class NightscoutCloudBackfillRoutingLogicSpy: NightscoutCloudBackfillRoutingLogic {
        
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = NightscoutCloudBackfillPresentationLogicSpy()
        sut.presenter = spy
        let request = NightscoutCloudBackfill.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}
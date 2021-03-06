//
//  NightscoutCloudExtraOptionsInteractorTests.swift
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

// swiftlint:disable implicitly_unwrapped_optional

final class NightscoutCloudExtraOptionsInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: NightscoutCloudExtraOptionsInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupNightscoutCloudExtraOptionsInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupNightscoutCloudExtraOptionsInteractor() {
        sut = NightscoutCloudExtraOptionsInteractor()
    }
    
    // MARK: Test doubles
    
    final class NightscoutCloudExtraOptionsPresentationLogicSpy: NightscoutCloudExtraOptionsPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: NightscoutCloudExtraOptions.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class NightscoutCloudExtraOptionsRoutingLogicSpy: NightscoutCloudExtraOptionsRoutingLogic {
        func routeToBackfillData() {
        }
        
        func presentNotYetImplementedAlert() {
        }
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = NightscoutCloudExtraOptionsPresentationLogicSpy()
        sut.presenter = spy
        let request = NightscoutCloudExtraOptions.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}

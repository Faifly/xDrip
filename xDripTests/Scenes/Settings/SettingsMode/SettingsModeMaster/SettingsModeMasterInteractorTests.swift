//
//  SettingsModeMasterInteractorTests.swift
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

final class SettingsModeMasterInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsModeMasterInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsModeMasterInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsModeMasterInteractor() {
        sut = SettingsModeMasterInteractor()
    }
    
    // MARK: Test doubles
    
    final class SettingsModeMasterPresentationLogicSpy: SettingsModeMasterPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: SettingsModeMaster.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class SettingsModeMasterRoutingLogicSpy: SettingsModeMasterRoutingLogic {
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = SettingsModeMasterPresentationLogicSpy()
        sut.presenter = spy
        let request = SettingsModeMaster.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}

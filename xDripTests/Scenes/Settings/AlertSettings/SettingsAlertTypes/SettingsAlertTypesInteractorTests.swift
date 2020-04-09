//
//  SettingsAlertTypesInteractorTests.swift
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

final class SettingsAlertTypesInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsAlertTypesInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsAlertTypesInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsAlertTypesInteractor() {
        sut = SettingsAlertTypesInteractor()
    }
    
    // MARK: Test doubles
    
    final class SettingsAlertTypesPresentationLogicSpy: SettingsAlertTypesPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: SettingsAlertTypes.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class SettingsAlertTypesRoutingLogicSpy: SettingsAlertTypesRoutingLogic {
        
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = SettingsAlertTypesPresentationLogicSpy()
        sut.presenter = spy
        let request = SettingsAlertTypes.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}

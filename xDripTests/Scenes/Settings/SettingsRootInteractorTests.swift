//
//  SettingsRootInteractorTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

final class SettingsRootInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsRootInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsRootInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsRootInteractor() {
        sut = SettingsRootInteractor()
    }
    
    // MARK: Test doubles
    
    final class SettingsRootPresentationLogicSpy: SettingsRootPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: SettingsRoot.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class SettingsRootRoutingLogicSpy: SettingsRootRoutingLogic {
        var dismissSelfCalled = false
        
        func dismissSelf() {
            dismissSelfCalled = true
        }
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = SettingsRootPresentationLogicSpy()
        sut.presenter = spy
        let request = SettingsRoot.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
    
    func testDoCancel() {
        // Given
        let spy = SettingsRootRoutingLogicSpy()
        sut.router = spy
        let request = SettingsRoot.Cancel.Request()
        
        // When
        sut.doCancel(request: request)
        
        // Then
        XCTAssertTrue(spy.dismissSelfCalled)
    }
}
//
//  SettingsModeRootInteractorTests.swift
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

final class SettingsModeRootInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsModeRootInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsModeRootInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsModeRootInteractor() {
        sut = SettingsModeRootInteractor()
    }
    
    // MARK: Test doubles
    
    final class SettingsModeRootPresentationLogicSpy: SettingsModeRootPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: SettingsModeRoot.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class SettingsModeRootRoutingLogicSpy: SettingsModeRootRoutingLogic {
        func presentSwitchingFromAuthorizedFollower(callback: @escaping (Bool) -> Void) {
        }
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = SettingsModeRootPresentationLogicSpy()
        sut.presenter = spy
        let request = SettingsModeRoot.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}

//
//  SettingsModeFollowerInteractorTests.swift
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

final class SettingsModeFollowerInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsModeFollowerInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsModeFollowerInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsModeFollowerInteractor() {
        sut = SettingsModeFollowerInteractor()
    }
    
    // MARK: Test doubles
    
    final class SettingsModeFollowerPresentationLogicSpy: SettingsModeFollowerPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: SettingsModeFollower.Load.Response) {
            presentLoadCalled = true
        }
        
        func presentUpdate(response: SettingsModeFollower.Update.Response) {
        }
    }
    
    final class SettingsModeFollowerRoutingLogicSpy: SettingsModeFollowerRoutingLogic {
        func showConnectionTestingAlert() {
        }
        
        func finishConnectionTestingAlert(message: String, icon: UIImage) {
        }
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = SettingsModeFollowerPresentationLogicSpy()
        sut.presenter = spy
        let request = SettingsModeFollower.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}

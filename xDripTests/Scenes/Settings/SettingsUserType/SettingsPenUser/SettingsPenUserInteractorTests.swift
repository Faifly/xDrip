//
//  SettingsPenUserInteractorTests.swift
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

final class SettingsPenUserInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsPenUserInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsPenUserInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsPenUserInteractor() {
        sut = SettingsPenUserInteractor()
    }
    
    // MARK: Test doubles
    
    final class SettingsPenUserPresentationLogicSpy: SettingsPenUserPresentationLogic {
        var presentUpdateDataCalled = false
        
        func presentUpdateData(response: SettingsPenUser.UpdateData.Response) {
            presentUpdateDataCalled = true
        }
    }
    
    final class SettingsPenUserRoutingLogicSpy: SettingsPenUserRoutingLogic {
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = SettingsPenUserPresentationLogicSpy()
        sut.presenter = spy
        let request = SettingsPenUser.UpdateData.Request(animated: false)
        
        // When
        sut.doUpdateData(request: request)
        
        // Then
        XCTAssertTrue(spy.presentUpdateDataCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}

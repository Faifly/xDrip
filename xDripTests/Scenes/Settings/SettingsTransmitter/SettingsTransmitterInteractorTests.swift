//
//  SettingsTransmitterInteractorTests.swift
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

final class SettingsTransmitterInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsTransmitterInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsTransmitterInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsTransmitterInteractor() {
        sut = SettingsTransmitterInteractor()
    }
    
    // MARK: Test doubles
    
    final class SettingsTransmitterPresentationLogicSpy: SettingsTransmitterPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: SettingsTransmitter.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class SettingsTransmitterRoutingLogicSpy: SettingsTransmitterRoutingLogic {        
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = SettingsTransmitterPresentationLogicSpy()
        sut.presenter = spy
        let request = SettingsTransmitter.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}

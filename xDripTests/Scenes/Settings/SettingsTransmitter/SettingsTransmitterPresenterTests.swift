//
//  SettingsTransmitterPresenterTests.swift
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

final class SettingsTransmitterPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsTransmitterPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsTransmitterPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsTransmitterPresenter() {
        sut = SettingsTransmitterPresenter()
    }
    
    // MARK: Test doubles
    
    final class SettingsTransmitterDisplayLogicSpy: SettingsTransmitterDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: SettingsTransmitter.Load.ViewModel) {
            displayLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = SettingsTransmitterDisplayLogicSpy()
        sut.viewController = spy
        let response = SettingsTransmitter.Load.Response()
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(spy.displayLoadCalled, "presentLoad(response:) should ask the view controller to display the result")
    }
}

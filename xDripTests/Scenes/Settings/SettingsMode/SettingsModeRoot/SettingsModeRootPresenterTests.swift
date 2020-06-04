//
//  SettingsModeRootPresenterTests.swift
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

final class SettingsModeRootPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsModeRootPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsModeRootPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsModeRootPresenter() {
        sut = SettingsModeRootPresenter()
    }
    
    // MARK: Test doubles
    
    final class SettingsModeRootDisplayLogicSpy: SettingsModeRootDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: SettingsModeRoot.Load.ViewModel) {
            displayLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = SettingsModeRootDisplayLogicSpy()
        sut.viewController = spy
        let response = SettingsModeRoot.Load.Response(mode: .main)
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(
            spy.displayLoadCalled,
            "presentLoad(response:) should ask the view controller to display the result"
        )
    }
}

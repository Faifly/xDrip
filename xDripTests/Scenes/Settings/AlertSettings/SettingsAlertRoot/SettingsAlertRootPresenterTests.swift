//
//  SettingsAlertRootPresenterTests.swift
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

final class SettingsAlertRootPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsAlertRootPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsAlertRootPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsAlertRootPresenter() {
        sut = SettingsAlertRootPresenter()
    }
    
    // MARK: Test doubles
    
    final class SettingsAlertRootDisplayLogicSpy: SettingsAlertRootDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: SettingsAlertRoot.Load.ViewModel) {
            displayLoadCalled = true
        }
        
        func displayUpdate(viewModel: SettingsAlertRoot.Load.ViewModel) {
            
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = SettingsAlertRootDisplayLogicSpy()
        sut.viewController = spy
        let response = SettingsAlertRoot.Load.Response(
            animated: false,
            sliderValueChangeHandler: { _ in },
            switchValueChangedHandler: { _, _ in},
            selectionHandler: {}
        )
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(
            spy.displayLoadCalled,
            "presentLoad(response:) should ask the view controller to display the result"
        )
    }
}

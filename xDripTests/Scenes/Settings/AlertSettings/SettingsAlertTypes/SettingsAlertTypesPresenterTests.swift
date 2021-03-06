//
//  SettingsAlertTypesPresenterTests.swift
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

final class SettingsAlertTypesPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsAlertTypesPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsAlertTypesPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsAlertTypesPresenter() {
        sut = SettingsAlertTypesPresenter()
    }
    
    // MARK: Test doubles
    
    final class SettingsAlertTypesDisplayLogicSpy: SettingsAlertTypesDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: SettingsAlertTypes.Load.ViewModel) {
            displayLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = SettingsAlertTypesDisplayLogicSpy()
        sut.viewController = spy
        let response = SettingsAlertTypes.Load.Response(
            defaultSectionTextEditingChangedHandler: { _ in },
            defaultSectionSwitchHandler: { _, _ in },
            defaultSectionPickerValueChangedHandler: { _ in },
            defaultSectionSelectionHandler: { _ in },
            eventsSectionSelectionHandler: { _ in }
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

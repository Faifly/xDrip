//
//  SettingsUserTypeRootPresenterTests.swift
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

final class SettingsUserTypeRootPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsUserTypeRootPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsUserTypeRootPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsUserTypeRootPresenter() {
        sut = SettingsUserTypeRootPresenter()
    }
    
    // MARK: Test doubles
    
    final class SettingsUserTypeRootDisplayLogicSpy: SettingsUserTypeRootDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: SettingsUserTypeRoot.Load.ViewModel) {
            displayLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = SettingsUserTypeRootDisplayLogicSpy()
        sut.viewController = spy
        let response = SettingsUserTypeRoot.Load.Response(injectionType: .pen)
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(
            spy.displayLoadCalled,
            "presentLoad(response:) should ask the view controller to display the result"
        )
    }
}

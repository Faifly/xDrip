//
//  NightscoutCloudExtraOptionsPresenterTests.swift
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

final class NightscoutCloudExtraOptionsPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: NightscoutCloudExtraOptionsPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupNightscoutCloudExtraOptionsPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupNightscoutCloudExtraOptionsPresenter() {
        sut = NightscoutCloudExtraOptionsPresenter()
    }
    
    // MARK: Test doubles
    
    final class NightscoutCloudExtraOptionsDisplayLogicSpy: NightscoutCloudExtraOptionsDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: NightscoutCloudExtraOptions.Load.ViewModel) {
            displayLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = NightscoutCloudExtraOptionsDisplayLogicSpy()
        sut.viewController = spy
        let response = NightscoutCloudExtraOptions.Load.Response()
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(
            spy.displayLoadCalled,
            "presentLoad(response:) should ask the view controller to display the result"
        )
    }
}

//
//  InitialSetupPresenterTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

final class InitialSetupPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: InitialSetupPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupInitialSetupPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupInitialSetupPresenter() {
        sut = InitialSetupPresenter()
    }
    
    // MARK: Test doubles
    
    final class InitialSetupDisplayLogicSpy: InitialSetupDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: InitialSetup.Load.ViewModel) {
            displayLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = InitialSetupDisplayLogicSpy()
        sut.viewController = spy
        let response = InitialSetup.Load.Response()
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(spy.displayLoadCalled, "presentLoad(response:) should ask the view controller to display the result")
    }
}
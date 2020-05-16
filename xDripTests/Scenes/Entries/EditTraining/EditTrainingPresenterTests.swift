//
//  EditTrainingPresenterTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class EditTrainingPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: EditTrainingPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupEditTrainingPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupEditTrainingPresenter() {
        sut = EditTrainingPresenter()
    }
    
    // MARK: Test doubles
    
    final class EditTrainingDisplayLogicSpy: EditTrainingDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: EditTraining.Load.ViewModel) {
            displayLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = EditTrainingDisplayLogicSpy()
        sut.viewController = spy
        let response = EditTraining.Load.Response()
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(
            spy.displayLoadCalled,
            "presentLoad(response:) should ask the view controller to display the result"
        )
    }
}

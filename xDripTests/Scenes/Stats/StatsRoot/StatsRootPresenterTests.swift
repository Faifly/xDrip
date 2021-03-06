//
//  StatsRootPresenterTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class StatsRootPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: StatsRootPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupStatsRootPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupStatsRootPresenter() {
        sut = StatsRootPresenter()
    }
    
    // MARK: Test doubles
    
    final class StatsRootDisplayLogicSpy: StatsRootDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: StatsRoot.Load.ViewModel) {
            displayLoadCalled = true
        }
        
        func displayChartData(viewModel: StatsRoot.UpdateChartData.ViewModel) {
        }
        
        func displayTableData(viewModel: StatsRoot.UpdateTableData.ViewModel) {
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = StatsRootDisplayLogicSpy()
        sut.viewController = spy
        let response = StatsRoot.Load.Response()
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(
            spy.displayLoadCalled,
            "presentLoad(response:) should ask the view controller to display the result"
        )
    }
}

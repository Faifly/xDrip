//
//  SettingsChartPresenterTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

final class SettingsChartPresenterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsChartPresenter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsChartPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsChartPresenter() {
        sut = SettingsChartPresenter()
    }
    
    // MARK: Test doubles
    
    final class SettingsChartDisplayLogicSpy: SettingsChartDisplayLogic {
        var displayLoadCalled = false
        
        func displayLoad(viewModel: SettingsChart.Load.ViewModel) {
            displayLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testPresentLoad() {
        // Given
        let spy = SettingsChartDisplayLogicSpy()
        sut.viewController = spy
        let response = SettingsChart.Load.Response(switchValueChangedHandler: { _,_ in}, singleSelectionHandler: { _ in })
        
        // When
        sut.presentLoad(response: response)
        
        // Then
        XCTAssertTrue(spy.displayLoadCalled, "presentLoad(response:) should ask the view controller to display the result")
    }
}

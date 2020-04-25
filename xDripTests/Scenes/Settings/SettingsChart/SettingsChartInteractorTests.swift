//
//  SettingsChartInteractorTests.swift
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

final class SettingsChartInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsChartInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSettingsChartInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsChartInteractor() {
        sut = SettingsChartInteractor()
    }
    
    // MARK: Test doubles
    
    final class SettingsChartPresentationLogicSpy: SettingsChartPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: SettingsChart.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class SettingsChartRoutingLogicSpy: SettingsChartRoutingLogic {
        
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = SettingsChartPresentationLogicSpy()
        sut.presenter = spy
        let request = SettingsChart.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}
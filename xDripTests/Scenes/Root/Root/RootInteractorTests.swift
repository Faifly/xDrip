//
//  RootInteractorTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class RootInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: RootInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupRootInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupRootInteractor() {
        sut = RootInteractor()
    }
    
    // MARK: Test doubles
    
    final class RootPresentationLogicSpy: RootPresentationLogic {
        var presentLoadCalled = false
        var presentAddEntryCalled = false
        var entryTypes: [Root.EntryType] = []
        
        func presentLoad(response: Root.Load.Response) {
            presentLoadCalled = true
        }
        
        func presentAddEntry(response: Root.ShowAddEntryOptionsList.Response) {
            presentAddEntryCalled = true
            entryTypes = response.types
        }
    }
    
    final class RootRoutingLogicSpy: RootRoutingLogic {
        var routeToCalibrationCalled = false
        var routeToStatsCalled = false
        var routeToHistoryCalled = false
        var routeToSettingsCalled = false
        
        func routeToCalibration() {
            routeToCalibrationCalled = true
        }
        
        func routeToStats() {
            routeToStatsCalled = true
        }
        
        func routeToHistory() {
            routeToHistoryCalled = true
        }
        
        func routeToSettings() {
            routeToSettingsCalled = true
        }
        
        func routeToAddFood() {
        }
        
        func routeToAddBolus() {
        }
        
        func routeToAddCarbs() {
        }
        
        func routeToAddTraining() {
        }
        
        func routeToInitialSetup() {
        }
        
        func showErrorAlert(title: String, message: String) {
        }
        
        func routeToAddBasal() {
        }
        
        func showNoBasalRatesAlert() {
        }
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = RootPresentationLogicSpy()
        sut.presenter = spy
        let request = Root.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
    
    func testTabBarSelection() {
        // Given
        let presenterSpy = RootPresentationLogicSpy()
        sut.presenter = presenterSpy
        
        let routerSpy = RootRoutingLogicSpy()
        sut.router = routerSpy
        
        // When
        var request = Root.TabSelection.Request(button: .calibration)
        sut.doTabSelection(request: request)
        // Then
//        XCTAssertTrue(routerSpy.routeToCalibrationCalled)
        
        // When
        request = Root.TabSelection.Request(button: .chart)
        sut.doTabSelection(request: request)
        // Then
        XCTAssertTrue(routerSpy.routeToStatsCalled)
        
        // When
        request = Root.TabSelection.Request(button: .history)
        sut.doTabSelection(request: request)
        // Then
        XCTAssertTrue(routerSpy.routeToHistoryCalled)
        
        // When
        request = Root.TabSelection.Request(button: .settings)
        sut.doTabSelection(request: request)
        // Then
        XCTAssertTrue(routerSpy.routeToSettingsCalled)
        
        // When
        request = Root.TabSelection.Request(button: .plus)
        sut.doTabSelection(request: request)
        // Then
        XCTAssertTrue(presenterSpy.presentAddEntryCalled)
        
        guard presenterSpy.entryTypes.count == 5 else {
            XCTFail("Expected entry types count: 5, found: \(presenterSpy.entryTypes.count)")
            return
        }
        
        XCTAssertTrue(presenterSpy.entryTypes[0] == .food)
        XCTAssertTrue(presenterSpy.entryTypes[1] == .bolus)
        XCTAssertTrue(presenterSpy.entryTypes[2] == .basal)
        XCTAssertTrue(presenterSpy.entryTypes[3] == .carbs)
        XCTAssertTrue(presenterSpy.entryTypes[4] == .training)
    }
}

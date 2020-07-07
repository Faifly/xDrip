//
//  HomeInteractorTests.swift
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

final class HomeInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: HomeInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupHomeInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupHomeInteractor() {
        sut = HomeInteractor()
    }
    
    // MARK: Test doubles
    
    final class HomePresentationLogicSpy: HomePresentationLogic {
        var presentLoadCalled = false
        var presentGlucoseCurrentInfoCalled = false
        
        func presentLoad(response: Home.Load.Response) {
            presentLoadCalled = true
        }
        
        func presentGlucoseData(response: Home.GlucoseDataUpdate.Response) {
        }
        
        func presentGlucoseChartTimeFrameChange(response: Home.ChangeGlucoseChartTimeFrame.Response) {
        }
        
        func presentGlucoseCurrentInfo(response: Home.GlucoseCurrentInfo.Response) {
            presentGlucoseCurrentInfoCalled = true
        }
        
        func presentWarmUp(response: Home.WarmUp.Response) {
        }
    }
    
    final class HomeRoutingLogicSpy: HomeRoutingLogic {
        var toCarbsCalled = false
        var toBolusCalled = false
        
        func routeToCarbsEntriesList() {
            toCarbsCalled = true
        }
        
        func routeToBolusEntriesList() {
            toBolusCalled = true
        }
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = HomePresentationLogicSpy()
        sut.presenter = spy
        let request = Home.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
        XCTAssertTrue(spy.presentGlucoseCurrentInfoCalled)
    }
    
    func testDoShowEntriesList() {
        let spy = HomeRoutingLogicSpy()
        sut.router = spy
        
        var request = Home.ShowEntriesList.Request(entriesType: .carbs)
        
        // When
        sut.doShowEntriesList(request: request)
        
        // Then
        XCTAssertTrue(spy.toCarbsCalled)
        
        request = Home.ShowEntriesList.Request(entriesType: .bolus)
        
        //When
        sut.doShowEntriesList(request: request)
        
        // Then
        XCTAssertTrue(spy.toBolusCalled)
    }
}

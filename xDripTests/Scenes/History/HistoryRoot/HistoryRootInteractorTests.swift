//
//  HistoryRootInteractorTests.swift
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

final class HistoryRootInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: HistoryRootInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupHistoryRootInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupHistoryRootInteractor() {
        sut = HistoryRootInteractor()
    }
    
    // MARK: Test doubles
    
    final class HistoryRootPresentationLogicSpy: HistoryRootPresentationLogic {
        var presentLoadCalled = false
        var presentGlucoseDataCalled = false
        var presentChartTimeFrameChangeCalled = false
        var timeInterval = 0.0
        
        func presentLoad(response: HistoryRoot.Load.Response) {
            presentLoadCalled = true
        }
        
        func presentGlucoseData(response: HistoryRoot.GlucoseDataUpdate.Response) {
            presentGlucoseDataCalled = true
        }
        
        func presentChartTimeFrameChange(response: HistoryRoot.ChangeEntriesChartTimeFrame.Response) {
            presentChartTimeFrameChangeCalled = true
            timeInterval = response.timeInterval
        }
    }
    
    final class HistoryRootRoutingLogicSpy: HistoryRootRoutingLogic {
        var dismissSelfCalled = false
        
        func dismissSelf() {
            dismissSelfCalled = true
        }
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = HistoryRootPresentationLogicSpy()
        sut.presenter = spy
        let request = HistoryRoot.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
        XCTAssertTrue(spy.presentGlucoseDataCalled)
    }
    
    func testDoCancel() {
        // Given
        let spy = HistoryRootRoutingLogicSpy()
        sut.router = spy
        let request = HistoryRoot.Cancel.Request()
        
        // When
        sut.doCancel(request: request)
        
        // Then
        XCTAssertTrue(spy.dismissSelfCalled)
    }
    
    func testDoChangeChartDate() {
        let spy = HistoryRootPresentationLogicSpy()
        sut.presenter = spy
        
        // When
        sut.doChangeChartDate(request: HistoryRoot.ChangeEntriesChartDate.Request(date: Date()))
        // Then
        XCTAssertTrue(spy.presentGlucoseDataCalled)
    }
    
    func testDoChangeChartTimeFrame() {
        let spy = HistoryRootPresentationLogicSpy()
        sut.presenter = spy
        
        // When
        sut.doChangeChartTimeFrame(request: HistoryRoot.ChangeEntriesChartTimeFrame.Request(timeline: .date))
        // Then
        XCTAssertTrue(spy.presentGlucoseDataCalled)
        XCTAssertTrue(spy.timeInterval == .secondsPerDay)
        
        // When
        sut.doChangeChartTimeFrame(request: HistoryRoot.ChangeEntriesChartTimeFrame.Request(timeline: .last14Days))
        // Then
        XCTAssertTrue(spy.timeInterval == TimeInterval(hours: 14.0 * 24.0))
    }
}

//
//  InitialSetupG6SensorAgeViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable discouraged_optional_boolean

final class InitialSetupG6SensorAgeViewControllerTests: XCTestCase {
    let sut = InitialSetupG6SensorAgeViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        func doClose() {}
        var calledCompleteSetup = false
        var moreStepsExpected: Bool?
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) {}
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doSaveNightscoutConnectionData(request: InitialSetup.SaveNightscoutCredentials.Request) { }
        func doFinishSetup(request: InitialSetup.FinishSetup.Request) { }
        
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) {
            calledCompleteSetup = true
            moreStepsExpected = request.moreStepsExpected
        }
        
        func doWarningAgreed(request: InitialSetup.WarningAgreed.Request) {}
    }
    
    func testOnSaveButton() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let datePicker = sut.view.subviews.compactMap({ $0 as? UIDatePicker }).first else {
            XCTFail("Cannot obtain datePicker")
            return
        }
        
        let date = Date(timeIntervalSince1970: 1.0)
        datePicker.date = date
        
        let button = sut.navigationItem.rightBarButtonItem
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup)
        XCTAssert(spy.moreStepsExpected == true)
//        XCTAssert(CGMDevice.current.sensorStartDate ~~ date)
    }
}

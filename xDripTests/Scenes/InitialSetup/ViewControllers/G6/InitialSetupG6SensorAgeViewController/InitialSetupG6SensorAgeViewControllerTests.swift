//
//  InitialSetupG6SensorAgeViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupG6SensorAgeViewControllerTests: XCTestCase {
    
    let sut = InitialSetupG6SensorAgeViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledCompleteSetup = false
        var moreStepsExpected: Bool? = nil
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) {}
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) {
            calledCompleteSetup = true
            moreStepsExpected = request.moreStepsExpected
        }
    }
    
    func testOnContinueButton() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let continueButton = sut.view.subviews.first(where: { $0.accessibilityIdentifier == "continueButton" }) as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        continueButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup)
        XCTAssert(spy.moreStepsExpected == true)
    }
}

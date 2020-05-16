//
//  InitialSetupG6DeviceIDViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable discouraged_optional_boolean

final class InitialSetupG6DeviceIDViewControllerTests: XCTestCase {
    let sut = InitialSetupG6DeviceIDViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledCompleteSetup = false
        var moreStepsExpected: Bool?
        
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
        
        guard let textField = sut.view.findView(with: "deviceIDTextField") as? UITextField else {
            XCTFail("Cannot obtain textfield")
            return
        }
        
        guard let continueButton = sut.view.findView(with: "continueButton") as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        continueButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup == false)
        XCTAssert(spy.moreStepsExpected == nil)
        
        // When
        textField.text = "123ABC"
        continueButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup == true)
        XCTAssert(spy.moreStepsExpected == true)
    }
}

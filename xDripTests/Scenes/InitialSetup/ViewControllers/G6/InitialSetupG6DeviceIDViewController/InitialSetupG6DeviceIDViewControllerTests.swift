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
    
    func testSaveButton() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let textField = sut.view.subviews.compactMap({ $0 as? UITextField }).first else {
            XCTFail("Cannot obtain textfield")
            return
        }
        
        let button = sut.navigationItem.rightBarButtonItem
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup == false)
        XCTAssert(spy.moreStepsExpected == nil)
        
        // When
        textField.text = "123ABC"
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup == true)
        XCTAssert(spy.moreStepsExpected == true)
        
        let serialNumber = CGMDevice.current.metadata(ofType: .serialNumber)
        XCTAssert(serialNumber?.value == "123ABC")
    }
    
    func testOpenGuideButton() {
        guard let button = sut.view.subviews.compactMap({ $0 as? UIButton }).first else {
            XCTFail("Cannot obtain button")
            return
        }
        
        button.sendActions(for: .touchUpInside)
    }
}

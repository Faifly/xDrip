//
//  InitialSetupG6WarmUpViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupG6WarmUpViewControllerTests: XCTestCase {
    
    let sut = InitialSetupG6WarmUpViewController()
    
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
    
    func test() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let finishButton = sut.view.findView(with: "finishButton") as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        finishButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup)
        XCTAssert(spy.moreStepsExpected == false)
    }
}

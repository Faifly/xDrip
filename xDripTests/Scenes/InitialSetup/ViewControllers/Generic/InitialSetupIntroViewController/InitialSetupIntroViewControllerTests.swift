//
//  InitialSetupIntroViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupIntroViewControllerTests: XCTestCase {
    
    let sut = InitialSetupIntroViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledSetup = false
        var calledSkip = false
        
        func doLoad(request: InitialSetup.Load.Request) { }
        
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) {
            calledSetup = true
        }
        
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) {
            calledSkip = true
        }
        
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) { }
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
    }
    
    func testOnBeginSetup() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let button = sut.view.subviews.first(where: { $0.accessibilityIdentifier == "beginSetupButton"}) as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        button.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledSetup)
    }
    
    func testOnSkipSetup() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let button = sut.view.subviews.first(where: { $0.accessibilityIdentifier == "skipButton" }) as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        button.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledSkip)
    }
}

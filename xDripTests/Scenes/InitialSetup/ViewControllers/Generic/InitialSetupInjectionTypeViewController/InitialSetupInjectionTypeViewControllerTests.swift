//
//  InitialSetupInjectionTypeViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupInjectionTypeViewControllerTests: XCTestCase {
    
    let sut = InitialSetupInjectionTypeViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledSelectInjectionType = false
        var injectionType: UserInjectionType? = nil
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) {}
        
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) {
            calledSelectInjectionType = true
            injectionType = request.injectionType
        }
        
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
    }
    
    func testButtonsCallback() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let penButton = sut.view.findView(with: "penButton") as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        penButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledSelectInjectionType)
        XCTAssert(spy.injectionType == .pen)
        
        guard let pumpButton = sut.view.findView(with: "pumpButton") as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        pumpButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.injectionType == .pump)
    }
}

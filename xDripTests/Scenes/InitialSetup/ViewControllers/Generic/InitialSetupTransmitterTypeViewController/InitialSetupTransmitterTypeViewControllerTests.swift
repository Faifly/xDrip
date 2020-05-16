//
//  InitialSetupTransmitterTypeViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupTransmitterTypeViewControllerTests: XCTestCase {    
    let sut = InitialSetupTransmitterTypeViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledSelectDeviceType = false
        var deviceType: CGMDeviceType?
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) { }
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) {
            calledSelectDeviceType = true
            deviceType = request.deviceType
        }
        
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
    }
    
    func testOnDexcomG6Selected() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let button = sut.view.findView(with: "dexcomG6Button") as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        button.sendActions(for: .touchUpInside)
        
        // Then
        XCTAssertTrue(spy.calledSelectDeviceType)
        XCTAssert(spy.deviceType == .dexcomG6)
    }
}

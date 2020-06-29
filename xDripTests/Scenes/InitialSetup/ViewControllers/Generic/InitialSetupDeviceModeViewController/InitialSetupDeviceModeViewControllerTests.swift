//
//  InitialSetupDeviceModeViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupDeviceModeViewControllerTests: XCTestCase {    
    let sut = InitialSetupDeviceModeViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledSelectDeviceMode = false
        var deviceMode: UserDeviceMode?
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSaveNightscoutConnectionData(request: InitialSetup.SaveNightscoutCredentials.Request) { }
        func doFinishSetup(request: InitialSetup.FinishSetup.Request) { }
        
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) {
            calledSelectDeviceMode = true
            deviceMode = request.deviceMode
        }
        
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
    }
    
    func testButtonsCallback() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        sut.loadViewIfNeeded()
        
        guard let mainButton = sut.navigationItem.rightBarButtonItem else {
            XCTFail("Cannot obtain button")
            return
        }
        guard let action = mainButton.action else {
            XCTFail("Cannot obtain action")
            return
        }
        
        // When
        UIApplication.shared.sendAction(action, to: mainButton.target, from: self, for: nil)
        // Then
        XCTAssertTrue(spy.calledSelectDeviceMode)
        XCTAssert(spy.deviceMode == .main)
    }
}

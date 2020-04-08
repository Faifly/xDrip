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
        var deviceMode: UserDeviceMode? = nil
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) {
            calledSelectDeviceMode = true
            deviceMode = request.deviceMode
        }
        
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
    }
    
    func test() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let mainButton = sut.view.findView(with: "mainButton") as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        mainButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledSelectDeviceMode)
        XCTAssert(spy.deviceMode == .main)
        
        guard let followerButton = sut.view.findView(with: "followerButton") as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        followerButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.deviceMode == .follower)
    }
}

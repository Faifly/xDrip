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
        func doClose() {}
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
        func doWarningAgreed(request: InitialSetup.WarningAgreed.Request) { }
    }
    
    func testButtonsCallback() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        sut.loadViewIfNeeded()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        guard let saveButton = sut.navigationItem.rightBarButtonItem else {
            XCTFail("Cannot obtain button")
            return
        }
        guard let action = saveButton.action else {
            XCTFail("Cannot obtain action")
            return
        }
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 1, section: 0))
        UIApplication.shared.sendAction(action, to: saveButton.target, from: self, for: nil)
        // Then
        XCTAssertTrue(spy.calledSelectDeviceMode)
        XCTAssert(spy.deviceMode == .follower)
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 0, section: 0))
        UIApplication.shared.sendAction(action, to: saveButton.target, from: self, for: nil)
        // Then
        XCTAssertTrue(spy.calledSelectDeviceMode)
        XCTAssert(spy.deviceMode == .main)
    }
}

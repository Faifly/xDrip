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
        var injectionType: UserInjectionType?
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) { }
        func doSaveNightscoutConnectionData(request: InitialSetup.SaveNightscoutCredentials.Request) { }
        func doFinishSetup(request: InitialSetup.FinishSetup.Request) { }
        
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) {
            calledSelectInjectionType = true
            injectionType = request.injectionType
        }
        
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
        func doWarningAgreed(request: InitialSetup.WarningAgreed.Request) {}
    }
    
    func testButtonsCallback() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        let button = sut.navigationItem.rightBarButtonItem
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 0, section: 0))
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(spy.calledSelectInjectionType)
        XCTAssert(spy.injectionType == .pen)
    }
}

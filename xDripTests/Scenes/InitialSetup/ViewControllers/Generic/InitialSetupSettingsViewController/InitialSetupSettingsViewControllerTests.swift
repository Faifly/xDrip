//
//  InitialSetupSettingsViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupSettingsViewControllerTests: XCTestCase {
    let sut = InitialSetupSettingsViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledSave = false
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) { }
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) {
            calledSave = true
        }
        
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
    }
    
    func testOnSaveSettings() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let button = sut.view.subviews.first(where: { $0.accessibilityIdentifier == "saveButton" }) as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        button.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledSave)
    }
}

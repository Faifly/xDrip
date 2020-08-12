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
        var selectedUnit: GlucoseUnit?
        var alertsEnabled = false
        var enabledNightscout = false
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) { }
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveNightscoutConnectionData(request: InitialSetup.SaveNightscoutCredentials.Request) { }
        func doFinishSetup(request: InitialSetup.FinishSetup.Request) { }
        
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) {
            calledSave = true
            selectedUnit = request.units
            alertsEnabled = request.alertsEnabled
            enabledNightscout = request.nightscoutEnabled
        }
        
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
    }
    
    func testInitialSettings() {
        User.current.settings.updateDeviceMode(.main)
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        let button = sut.navigationItem.rightBarButtonItem
        
        XCTAssertTrue(tableView.numberOfSections == 3)
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 0, section: 0))
        tableView.callDidSelect(at: IndexPath(row: 0, section: 1))
        tableView.callDidSelect(at: IndexPath(row: 1, section: 2))
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssert(spy.selectedUnit == .mgDl)
        XCTAssertTrue(spy.alertsEnabled)
        XCTAssertTrue(spy.enabledNightscout)
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 1, section: 0))
        tableView.callDidSelect(at: IndexPath(row: 1, section: 1))
        tableView.callDidSelect(at: IndexPath(row: 0, section: 2))
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssert(spy.selectedUnit == .mmolL)
        XCTAssertFalse(spy.alertsEnabled)
        XCTAssertFalse(spy.enabledNightscout)
    }
    
    func testFollowerMode() {
        User.current.settings.updateDeviceMode(.follower)
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssertTrue(tableView.numberOfSections == 2)
    }
}

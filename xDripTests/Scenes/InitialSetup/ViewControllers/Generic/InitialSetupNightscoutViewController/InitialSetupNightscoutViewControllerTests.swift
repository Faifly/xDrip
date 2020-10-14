//
//  InitialSetupNightscoutViewControllerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 12.08.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable implicitly_unwrapped_optional
final class InitialSetupNightscoutViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: InitialSetupNightscoutViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupInitialSetupNightscoutViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupInitialSetupNightscoutViewController() {
        sut = InitialSetupNightscoutViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var doSaveNightscoutConnectionDataCalled = false
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) { }
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveNightscoutConnectionData(request: InitialSetup.SaveNightscoutCredentials.Request) {
            doSaveNightscoutConnectionDataCalled = true
        }
        func doFinishSetup(request: InitialSetup.FinishSetup.Request) { }
        
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
        func doWarningAgreed(request: InitialSetup.WarningAgreed.Request) {}
    }
    
    func testNightscoutConnectionMainMode() {
        User.current.settings.updateDeviceMode(.main)
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        let saveButton = sut.navigationItem.rightBarButtonItem
        
        XCTAssert(saveButton?.isEnabled == false)
        XCTAssert(tableView.numberOfRows(inSection: 0) == 3)
        
        let buttonCellType = BaseSettingsButtonCell.self
        guard let cell = tableView.getCell(of: buttonCellType, at: IndexPath(row: 2, section: 0)),
            let button = cell.contentView.subviews.compactMap({ $0 as? UIButton }).first else {
            XCTFail("Cannot obtain button")
            return
        }
        
        button.sendActions(for: .touchUpInside)
    }
    
    func testNightscoutConnectionFollowerMode() {
        User.current.settings.updateDeviceMode(.follower)
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        let buttonCellType = BaseSettingsButtonCell.self
        guard let cell = tableView.getCell(of: buttonCellType, at: IndexPath(row: 2, section: 0)),
            let button = cell.contentView.subviews.compactMap({ $0 as? UIButton }).first else {
            XCTFail("Cannot obtain button")
            return
        }
        
        button.sendActions(for: .touchUpInside)
    }
    
    func testTextFieldCallbacks() {
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        let saveButton = sut.navigationItem.rightBarButtonItem
        
        XCTAssert(saveButton?.isEnabled == false)
        XCTAssert(tableView.numberOfRows(inSection: 0) == 3)
        
        let textFieldCellType = BaseSettingsTextInputTableViewCell.self
        guard
            let baseURLCell = tableView.getCell(of: textFieldCellType, at: IndexPath(row: 0, section: 0)),
            let baseURLTextField = baseURLCell.findView(with: "textField") as? UITextField,
            let apiSecretCell = tableView.getCell(of: textFieldCellType, at: IndexPath(row: 1, section: 0)),
            let apiSecretTextField = apiSecretCell.findView(with: "textField") as? UITextField else {
            XCTFail("Cannot obtain textFields")
            return
        }
        
        baseURLTextField.text = "https://test-url.com"
        apiSecretTextField.text = "test-api-secret"
    }
    
    func testSaveButton() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        loadView()
        
        let button = sut.navigationItem.rightBarButtonItem
        button?.isEnabled = true
        _ = button?.target?.perform(button?.action, with: nil)
        
        XCTAssertTrue(spy.doSaveNightscoutConnectionDataCalled)
    }
}

//
//  NightscoutCloudConfigurationViewControllerTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class NightscoutCloudConfigurationViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: NightscoutCloudConfigurationViewController!
    var window: UIWindow!
    var tableView: UITableView!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupNightscoutCloudConfigurationViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupNightscoutCloudConfigurationViewController() {
        sut = NightscoutCloudConfigurationViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        self.tableView = tableView
    }
    
    // MARK: Test doubles
    
    final class NightscoutCloudConfigurationBusinessLogicSpy: NightscoutCloudConfigurationBusinessLogic {
        var doLoadCalled = false
        
        func doUpdateData(request: NightscoutCloudConfiguration.UpdateData.Request) {
            doLoadCalled = true
        }
    }
    
    final class NightscoutCloudConfigurationRoutingLogicSpy: NightscoutCloudConfigurationRoutingLogic {
        var routeToExtraOptionsCalled = false
        
        func routeToExtraOptions() {
            routeToExtraOptionsCalled = true
        }
        
        func showConnectionTestingAlert() {
        }
        
        func presentNotYetImplementedAlert() {
        }
        
        func finishConnectionTestingAlert(message: String, icon: UIImage) {
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = NightscoutCloudConfigurationBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let tableViewModel = BaseSettings.ViewModel(sections: [])
        let viewModel = NightscoutCloudConfiguration.UpdateData.ViewModel(tableViewModel: tableViewModel)
        
        // When
        loadView()
        sut.displayData(viewModel: viewModel)
        
        // Then
    }
    
    func testEnabledSwitchValueChanged() {
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let enabledCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 0)),
            let enabledSwitch = enabledCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        
        let settings = User.current.settings.nightscoutSync
        
        // When
        enabledSwitch.isOn = true
        enabledSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.isEnabled == true)
        
        // When
        enabledSwitch.isOn = false
        enabledSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.isEnabled == false)
    }
    
    func testCellularSwitchValueChanged() {
        User.current.settings.nightscoutSync?.updateIsEnabled(true)
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let cellularCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 1)),
            let cellularSwitch = cellularCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        let settings = User.current.settings.nightscoutSync
        
        // When
        cellularSwitch.isOn = true
        cellularSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.useCellularData == true)
        
        // When
        cellularSwitch.isOn = false
        cellularSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.useCellularData == false)
    }
    
    func testGlucoseSwitchValueChanged() {
        User.current.settings.nightscoutSync?.updateIsEnabled(true)
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let glucoseCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 2)),
            let glucoseSwitch = glucoseCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        let settings = User.current.settings.nightscoutSync
        
        // When
        glucoseSwitch.isOn = true
        glucoseSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.sendDisplayGlucose == true)
        
        // When
        glucoseSwitch.isOn = false
        glucoseSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.sendDisplayGlucose == false)
    }
    
    func testDataSwitchValueChanged() {
        User.current.settings.nightscoutSync?.updateIsEnabled(true)
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let dataCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 4)),
            let dataSwitch = dataCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        let settings = User.current.settings.nightscoutSync
            
        // When
        dataSwitch.setOn(true, animated: false)
        dataSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.downloadData == dataSwitch.isOn)
        
        // When
        dataSwitch.setOn(false, animated: false)
        dataSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.downloadData == dataSwitch.isOn)
    }
    
    func testTextEditingChangedHandler() {
        User.current.settings.nightscoutSync?.updateIsEnabled(true)
        loadView()
        
        let cellType = BaseSettingsTextInputTableViewCell.self
        
        guard let textCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 3)),
            let textField = textCell.findView(with: "textField") as? UITextField else {
                XCTFail("Cannot obtain textField")
                return
        }
        
        let settings = User.current.settings.nightscoutSync
        
        // When
        textField.text = "url"
        textField.sendActions(for: .editingChanged)
        // Then
        XCTAssertTrue(settings?.baseURL == "url")
    }
    
    func testSingleSelectionHandler() {
        User.current.settings.nightscoutSync?.updateIsEnabled(true)
        loadView()
        
        let spy = NightscoutCloudConfigurationRoutingLogicSpy()
        if let interactor = sut.interactor as? NightscoutCloudConfigurationInteractor {
            interactor.router = spy
        }
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 0, section: 5))
        // Then
        XCTAssertTrue(spy.routeToExtraOptionsCalled)
    }
}

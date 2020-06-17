//
//  NightscoutCloudExtraOptionsViewControllerTests.swift
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

final class NightscoutCloudExtraOptionsViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: NightscoutCloudExtraOptionsViewController!
    var window: UIWindow!
    var tableView: UITableView!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupNightscoutCloudExtraOptionsViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupNightscoutCloudExtraOptionsViewController() {
        sut = NightscoutCloudExtraOptionsViewController()
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
    
    final class NightscoutCloudExtraOptionsBusinessLogicSpy: NightscoutCloudExtraOptionsBusinessLogic {
        var doLoadCalled = false
        
        func doLoad(request: NightscoutCloudExtraOptions.Load.Request) {
            doLoadCalled = true
        }
    }
    
    final class NightscoutCloudExtraOptionsRoutingLogicSpy: NightscoutCloudExtraOptionsRoutingLogic {
        var routeToBackfillCalled = false
        
        func routeToBackfillData() {
            routeToBackfillCalled = true
        }
        
        func presentNotYetImplementedAlert() {
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = NightscoutCloudExtraOptionsBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let tableViewModel = BaseSettings.ViewModel(sections: [])
        let viewModel = NightscoutCloudExtraOptions.Load.ViewModel(tableViewModel: tableViewModel)
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
        // Then
    }
    
    func testSwitchValueChangedHandler() {
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let skipCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 0)),
            let skipSwitch = skipCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        
        let settings = User.current.settings.nightscoutSync
        
        // When
        skipSwitch.isOn = true
        skipSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.skipLANUploads == false)
        
        // When
        skipSwitch.isOn = false
        skipSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.skipLANUploads == false)
    }
    
    func testBatteryValueChanged() {
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let batteryCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 1)),
            let batterySwitch = batteryCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        
        let settings = User.current.settings.nightscoutSync
        
        // When
        batterySwitch.isOn = true
        batterySwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.uploadBridgeBattery == false)
        
        // When
        batterySwitch.isOn = false
        batterySwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.uploadBridgeBattery == false)
    }
    
    func testTreatmentsValueChanged() {
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let treatmentsCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 2)),
            let treatmentsSwitch = treatmentsCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        
        let settings = User.current.settings.nightscoutSync
        
        // When
        treatmentsSwitch.isOn = true
        treatmentsSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.uploadTreatments == false)
        
        // When
        treatmentsSwitch.isOn = false
        treatmentsSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.uploadTreatments == false)
    }
    
    func testAlertValueChanged() {
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let alertCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 3)),
            let alertSwitch = alertCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        
        let settings = User.current.settings.nightscoutSync
        
        // When
        alertSwitch.isOn = true
        alertSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.alertOnFailures == false)
        
        // When
        alertSwitch.isOn = false
        alertSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.alertOnFailures == false)
    }
    
    func testSourceInfoValueChanged() {
        loadView()
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        guard let sourceInfoCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 4)),
            let sourceInfoSwitch = sourceInfoCell.accessoryView as? UISwitch else {
                XCTFail("Cannot obtain switches")
                return
        }
        
        let settings = User.current.settings.nightscoutSync
        
        // When
        sourceInfoSwitch.isOn = true
        sourceInfoSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.appendSourceInfoToDevices == false)
        
        // When
        sourceInfoSwitch.isOn = false
        sourceInfoSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssert(settings?.appendSourceInfoToDevices == false)
    }
    
    func testSingleSelectionHandler() {
        loadView()
        
        let spy = NightscoutCloudExtraOptionsRoutingLogicSpy()
        if let interactor = sut.interactor as? NightscoutCloudExtraOptionsInteractor {
            interactor.router = spy
        }
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 0, section: 5))
        // Then
//        XCTAssertTrue(spy.routeToBackfillCalled)
    }
}

//
//  SettingsChartViewControllerTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class SettingsChartViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsChartViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSettingsChartViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsChartViewController() {
        sut = SettingsChartViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class SettingsChartBusinessLogicSpy: SettingsChartBusinessLogic {
        var doLoadCalled = false
        
        func doLoad(request: SettingsChart.Load.Request) {
            doLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = SettingsChartBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let viewModel = SettingsChart.Load.ViewModel(tableViewModel: BaseSettings.ViewModel(sections: []))
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
        // Then
    }
    
    func testSwitchHandler() {
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssert(tableView.numberOfSections == 2)
        XCTAssert(tableView.numberOfRows(inSection: 0) == 3)
        XCTAssert(tableView.numberOfRows(inSection: 1) == 3)
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        
        guard let activeInsulinCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 0)),
            let activeCarbsCell = tableView.getCell(of: cellType, at: IndexPath(row: 1, section: 0)),
            let dataCell = tableView.getCell(of: cellType, at: IndexPath(row: 2, section: 0)),
            let insulinSwitch = activeInsulinCell.accessoryView as? UISwitch,
            let carbsSwitch = activeCarbsCell.accessoryView as? UISwitch,
            let dataSwitch = dataCell.accessoryView as? UISwitch else {
            XCTFail("Cannot obtain right switch")
            return
        }
        
        // Default
        XCTAssertTrue(User.current.settings.chart?.showActiveInsulin == true)
        XCTAssertTrue(User.current.settings.chart?.showActiveCarbs == true)
        XCTAssertTrue(User.current.settings.chart?.showData == true)
        
        // When
        insulinSwitch.setOn(false, animated: true)
        insulinSwitch.sendActions(for: .valueChanged)
        carbsSwitch.setOn(false, animated: true)
        carbsSwitch.sendActions(for: .valueChanged)
        dataSwitch.setOn(false, animated: true)
        dataSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(User.current.settings.chart?.showActiveInsulin == false)
        XCTAssertTrue(User.current.settings.chart?.showActiveCarbs == false)
        XCTAssertTrue(User.current.settings.chart?.showData == false)
    }
    
    func testSingleSelectionHandler() {
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssert(tableView.numberOfSections == 2)
        XCTAssert(tableView.numberOfRows(inSection: 0) == 3)
        XCTAssert(tableView.numberOfRows(inSection: 1) == 3)
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 0, section: 1))
        // Then
        XCTAssertTrue(User.current.settings.chart?.basalDisplayMode == .onTop)
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 1, section: 1))
        // Then
        XCTAssertTrue(User.current.settings.chart?.basalDisplayMode == .onBottom)
        
        // When
        tableView.callDidSelect(at: IndexPath(row: 2, section: 1))
        // Then
        XCTAssertTrue(User.current.settings.chart?.basalDisplayMode == .notShown)
    }
}

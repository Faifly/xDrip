//
//  SettingsPenUserViewControllerTests.swift
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

final class SettingsPenUserViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsPenUserViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSettingsPenUserViewController()
    }
    
    override func tearDown() {
        window = nil
        clearBasalRates()
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsPenUserViewController() {
        sut = SettingsPenUserViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class SettingsPenUserBusinessLogicSpy: SettingsPenUserBusinessLogic {
        var doUpdateDataCalled = false
        var doAddCalled = false
        var doDeleteCalled = false
        
        func doUpdateData(request: SettingsPenUser.UpdateData.Request) {
            doUpdateDataCalled = true
        }
        
        func doAdd(request: SettingsPenUser.Add.Request) {
            doAddCalled = true
        }
        
        func doDelete(request: SettingsPenUser.Delete.Request) {
            doDeleteCalled = true
        }
    }
    
    final class ViewControllerSpy: SettingsPenUserViewController {
        var lastPresentedViewController: UIViewController?
        override func present(_ viewControllerToPresent: UIViewController,
                              animated flag: Bool,
                              completion: (() -> Void)? = nil) {
            lastPresentedViewController = viewControllerToPresent
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = SettingsPenUserBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doUpdateDataCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let viewModel = SettingsPenUser.UpdateData.ViewModel(
            animated: false,
            tableViewModel: BaseSettings.ViewModel(sections: [])
        )
        
        // When
        loadView()
        sut.displayUpdateData(viewModel: viewModel)
        
        // Then
    }
    
    func testNavigationItem() {
        let containerController = UITabBarController()
        containerController.viewControllers = [sut]
        let navigationController = UINavigationController(rootViewController: containerController)
        loadView()
        
        // When
        sut.viewWillAppear(false)
        // Then
        XCTAssertNotNil(navigationController.navigationItem.rightBarButtonItem)
        
        // When
        sut.viewWillDisappear(false)
        // Then
        XCTAssertNil(navigationController.navigationItem.rightBarButtonItem)
    }
    
    func testDoAddShouldCalledWhenPressedOnRightBarButton() {
        let spy = SettingsPenUserBusinessLogicSpy()
        sut.interactor = spy
        
        let containerController = UITabBarController()
        containerController.viewControllers = [sut]
        let navigationController = UINavigationController(rootViewController: containerController)
        loadView()
        
        sut.viewWillAppear(false)
        
        let button = navigationController.navigationItem.rightBarButtonItem
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(spy.doAddCalled)
    }
    
    func testDoAddAndDoDelete() {
        let spy = ViewControllerSpy()
        sut = spy
        let containerController = UITabBarController()
        containerController.viewControllers = [sut]
        let navigationController = UINavigationController(rootViewController: containerController)
        loadView()
        
        sut.viewWillAppear(false)
        
        let button = navigationController.navigationItem.rightBarButtonItem
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssertTrue(tableView.numberOfSections == 2)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 0)
        XCTAssertTrue(tableView.numberOfRows(inSection: 1) == 1)
        
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 1)
        
        // When
        sut.tableView(tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        
        guard let alertController = spy.lastPresentedViewController as? UIAlertController else {
            XCTFail("Cannot obtain alertContrtoller")
            return
        }
        
        guard let action = alertController.actions.first(where: { $0.style == .destructive }) else {
            XCTFail("Cannot obtain action")
            return
        }
        alertController.sendAction(action: action)
        
        // Then
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 0)
    }
    
    func testTableView() {
        let containerController = UITabBarController()
        containerController.viewControllers = [sut]
        let navigationController = UINavigationController(rootViewController: containerController)
        loadView()
        
        sut.viewWillAppear(false)
        
        let button = navigationController.navigationItem.rightBarButtonItem
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 1)
        
        XCTAssertTrue(sut.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 0)))
        XCTAssert(sut.tableView(tableView, editingStyleForRowAt: IndexPath(row: 0, section: 0)) == .delete)
        XCTAssertFalse(sut.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 1)))
        XCTAssert(sut.tableView(tableView, editingStyleForRowAt: IndexPath(row: 0, section: 1)) == .none)
        
        tableView.callDidSelect(at: IndexPath(row: 0, section: 0))
        
        XCTAssertFalse(sut.tableView(tableView, canEditRowAt: IndexPath(row: 0, section: 0)))
        XCTAssert(sut.tableView(tableView, editingStyleForRowAt: IndexPath(row: 0, section: 0)) == .none)
    }
    
    func testBasalRatePickerValueChanged() {
        let containerController = UITabBarController()
        containerController.viewControllers = [sut]
        let navigationController = UINavigationController(rootViewController: containerController)
        loadView()

        sut.viewWillAppear(false)

        let button = navigationController.navigationItem.rightBarButtonItem

        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
           XCTFail("Cannot obtain tableView")
           return
        }
        
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 0)

        // When
        _ = button?.target?.perform(button?.action, with: nil)
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 1)
        
        let pickerType = PickerExpandableTableViewCell.self
        guard let pickerCell = tableView.getCell(of: pickerType, at: IndexPath(row: 0, section: 0)) else {
            XCTFail("Cannot obtain pickerCell")
            return
        }
        
        pickerCell.togglePickerVisibility()
        
        guard let stackView = pickerCell.contentView.subviews.compactMap({ $0 as? UIStackView }).first,
            let picker = stackView.arrangedSubviews.first as? CustomPickerView else {
            XCTFail("Cannot obtain picker")
            return
        }
        
        XCTAssertTrue(picker.numberOfComponents == 6)
        
        // When
        picker.selectRow(10, inComponent: 0, animated: false)
        picker.selectRow(5, inComponent: 2, animated: false)
        picker.selectRow(2, inComponent: 4, animated: false)
        picker.pickerView(picker, didSelectRow: 2, inComponent: 4)
        // Then
        let settings = User.current.settings
        let rate = settings?.sortedBasalRates.first
        XCTAssert(rate?.startTime == 36300) // 10*3600 + 5*60
        XCTAssert(rate?.units == 0.1)
        
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 2)
        
        let disclosureType = BaseSettingsDisclosureCell.self
        guard let infoCell = tableView.getCell(of: disclosureType, at: IndexPath(row: 0, section: 1)) else {
            XCTFail("Cannot obtain info cell")
            return
        }
        
        let text = "0.10" + "settings_pen_user_u".localized
        XCTAssertTrue(infoCell.detailTextLabel?.text == text)
    }
    
    func clearBasalRates() {
        let basalRates = User.current.settings.sortedBasalRates
        
        for rate in basalRates {
            User.current.settings.deleteBasalRate(rate)
        }
    }
}

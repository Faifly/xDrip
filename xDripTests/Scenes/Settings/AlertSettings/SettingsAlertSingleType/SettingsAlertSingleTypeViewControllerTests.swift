//
//  SettingsAlertSingleTypeViewControllerTests.swift
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

final class SettingsAlertSingleTypeViewControllerTests: AbstractRealmTest {
    // MARK: Subject under test
    
    var sut: SettingsAlertSingleTypeViewController!
    var window: UIWindow!
    
    var tableView: UITableView!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSettingsAlertSingleTypeViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsAlertSingleTypeViewController() {
        sut = SettingsAlertSingleTypeViewController()
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
    
    final class SettingsAlertSingleTypeBusinessLogicSpy: SettingsAlertSingleTypeBusinessLogic {
        var doLoadCalled = false
        
        func doLoad(request: SettingsAlertSingleType.Load.Request) {
            doLoadCalled = true
        }
    }
    
    final class SettingsAlertSingleTypeRoutingLogicSpy: SettingsAlertSingleTypeRoutingLogic {
        var routeToSoundCalled = false
        
        func routeToSound() {
            routeToSoundCalled = true
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = SettingsAlertSingleTypeBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testTableView() {
        sut.router?.dataStore?.eventType = .fastRise
        loadView()
        
        let configuration = sut.router?.dataStore?.configuration
        
        XCTAssertTrue(tableView.numberOfSections == 2)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 2)
        
        // When
        toggleSecondSection(expanded: false)
        // Then
        XCTAssertTrue(configuration?.isOverriden == false)
        XCTAssertTrue(tableView.numberOfRows(inSection: 1) == 5)
        
        // When
        toggleSecondSection(expanded: true)
        // Then
        XCTAssertTrue(configuration?.isOverriden == true)
        XCTAssertTrue(tableView.numberOfRows(inSection: 1) == 11)
        
        // When
        toggleEntireDaySwitch(expanded: true, isSecondSectionExpanded: true)
        // Then
        XCTAssertTrue(configuration?.isEntireDay == true)
        XCTAssertTrue(tableView.numberOfRows(inSection: 1) == 11)

        // When
        toggleEntireDaySwitch(expanded: false, isSecondSectionExpanded: true)
        // Then
        XCTAssertTrue(configuration?.isEntireDay == false)
        XCTAssertTrue(tableView.numberOfRows(inSection: 1) == 13)
    }
    
    func testSwitchValueChangedHandler() {
        sut.router?.dataStore?.eventType = .fastRise
        loadView()
        
        let configuration = sut.router?.dataStore?.configuration
        
        toggleSecondSection(expanded: true)
        
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        
        guard let snoozeOnCell = tableView.getCell(of: cellType, at: IndexPath(row: 1, section: 1)),
            let repeatCell = tableView.getCell(of: cellType, at: IndexPath(row: 3, section: 1)),
            let vibrateCell = tableView.getCell(of: cellType, at: IndexPath(row: 5, section: 1)),
            let snoozeSwitch = snoozeOnCell.accessoryView as? UISwitch,
            let repeatSwitch = repeatCell.accessoryView as? UISwitch,
            let vibrateSwitch = vibrateCell.accessoryView as? UISwitch else {
            XCTFail("Cannot obtain switch")
            return
        }
        // When
        snoozeSwitch.isOn = false
        snoozeSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(configuration?.snoozeFromNotification == false)
        
        // When
        snoozeSwitch.isOn = true
        snoozeSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(configuration?.snoozeFromNotification == true)
        
        // When
        repeatSwitch.isOn = false
        repeatSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(configuration?.repeat == false)
        
        // When
        repeatSwitch.isOn = true
        repeatSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(configuration?.repeat == true)
        
        // When
        vibrateSwitch.isOn = false
        vibrateSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(configuration?.isVibrating == false)
        
        // When
        vibrateSwitch.isOn = true
        vibrateSwitch.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(configuration?.isVibrating == true)
    }
    
    func testTextEditingChangedHandler() {
        loadView()
        
        let configuration = sut.router?.dataStore?.configuration
        
        toggleSecondSection(expanded: true)
        
        let cellType = BaseSettingsTextInputTableViewCell.self
        
        guard let textFieldCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 1)),
            let textField = textFieldCell.findView(with: "textField") as? UITextField else {
            XCTFail("Cannot obtain textField")
            return
        }
        // When
        textField.text = "Test Name"
        textField.sendActions(for: .editingChanged)
        // Then
        XCTAssertTrue(configuration?.name == "Test Name")
    }
    
    func testSnoozePickerValueChanged() {
        loadView()
        
        let configuration = sut.router?.dataStore?.configuration
        
        toggleSecondSection(expanded: true)
        
        guard let pickerView = getPicker(tableView, at: IndexPath(row: 2, section: 1)) as? CustomPickerView else {
            XCTFail("Cannot obtain pickerView")
            return
        }
        // When
        pickerView.selectRow(12, inComponent: 2, animated: false)
        pickerView.pickerView(pickerView, didSelectRow: 12, inComponent: 2)
        // Then
        XCTAssertTrue(configuration?.defaultSnooze == 12.0 * TimeInterval.secondsPerMinute)
    }
    
    func testTimePickerValueChanged() {
        sut.router?.dataStore?.eventType = .fastRise
        loadView()
        
        let configuration = sut.router?.dataStore?.configuration
        
        toggleSecondSection(expanded: false)
        toggleEntireDaySwitch(expanded: false, isSecondSectionExpanded: false)
        
        let startTime = Date(timeIntervalSince1970: 3600.0)
        let endTime = Date(timeIntervalSince1970: 7200.0)
        
        guard let startPickerView = getPicker(tableView, at: IndexPath(row: 1, section: 1)) as? CustomDatePicker,
            let endPickerView = getPicker(tableView, at: IndexPath(row: 2, section: 1)) as? CustomDatePicker else {
            XCTFail("Cannot obtain pickerView")
            return
        }
        // When
        startPickerView.setDate(startTime, animated: false)
        startPickerView.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(configuration?.startTime == startTime.timeIntervalSince1970)
        
        // When
        endPickerView.setDate(endTime, animated: false)
        endPickerView.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(configuration?.endTime == endTime.timeIntervalSince1970)
    }
    
    func testPickerValueChangedHandler() {
        User.current.settings.updateUnit(.mgDl)
        sut.router?.dataStore?.eventType = .fastDrop
        
        loadView()
        
        let configuration = sut.router?.dataStore?.configuration
        
        toggleSecondSection(expanded: false)
        toggleEntireDaySwitch(expanded: false, isSecondSectionExpanded: false)
        
        guard let highPickerView = getPicker(tableView, at: IndexPath(row: 4, section: 1)) as? CustomPickerView else {
            XCTFail("Cannot obtain picker view")
            return
        }
        // When
        highPickerView.selectRow(12, inComponent: 0, animated: false)
        highPickerView.pickerView(highPickerView, didSelectRow: 12, inComponent: 0)
        // Then
        XCTAssertTrue(configuration?.highThreshold == 12.0)
    }
    
    func testMmolUnitPickerValueChangedHandler() {
        User.current.settings.updateUnit(.mmolL)
        sut.router?.dataStore?.eventType = .fastRise
        
        loadView()
        
        let configuration = sut.router?.dataStore?.configuration
        
        toggleSecondSection(expanded: false)
        toggleEntireDaySwitch(expanded: false, isSecondSectionExpanded: false)
        
        guard let lowPickerView = getPicker(tableView, at: IndexPath(row: 5, section: 1)) as? CustomPickerView else {
            XCTFail("Cannot obtain picker view")
            return
        }
        
        // When
        lowPickerView.selectRow(12, inComponent: 0, animated: false)
        lowPickerView.pickerView(lowPickerView, didSelectRow: 12, inComponent: 0)
        // Then
        
        var value: Float = 0.0
        if let val = lowPickerView.pickerView(lowPickerView, titleForRow: 12, forComponent: 0),
            let valueToConvert = Double(val) {
            value = Float(GlucoseUnit.convertToDefault(valueToConvert))
        }
        // Then
        XCTAssertTrue(configuration?.lowThreshold == value)
    }
    
    func testMinimumBGChangeHandler() {
        User.current.settings.updateUnit(.mgDl)
        sut.router?.dataStore?.eventType = .fastDrop
        
        loadView()
        
        let configuration = sut.router?.dataStore?.configuration
        
        toggleSecondSection(expanded: false)
        toggleEntireDaySwitch(expanded: false, isSecondSectionExpanded: false)
        
        guard let bgPickerView = getPicker(tableView, at: IndexPath(row: 6, section: 1)) as? CustomPickerView else {
            XCTFail("Cannot obtain picker view")
            return
        }
        
        // When
        bgPickerView.selectRow(12, inComponent: 0, animated: false)
        bgPickerView.pickerView(bgPickerView, didSelectRow: 12, inComponent: 0)
        // Then
        XCTAssertTrue(configuration?.minimumBGChange == 12.0)
    }
    
    func testSingleSelectionHandler() {
        sut.router?.dataStore?.eventType = .fastRise
        loadView()
        
        let routerSpy = SettingsAlertSingleTypeRoutingLogicSpy()
        if let interactor = sut.interactor as? SettingsAlertSingleTypeInteractor {
            interactor.router = routerSpy
        }
        
        toggleSecondSection(expanded: true)
        // When
        tableView.callDidSelect(at: IndexPath(row: 4, section: 1))
        // Then
        XCTAssertTrue(routerSpy.routeToSoundCalled)
    }
    
    func toggleSecondSection(expanded: Bool) {
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        
        guard let overrideDefaultCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 0)),
            let switchDefault = overrideDefaultCell.accessoryView as? UISwitch else {
            XCTFail("Cannot obtain switch cell")
            return
        }
        switchDefault.isOn = expanded
        switchDefault.sendActions(for: .valueChanged)
    }
    
    func toggleEntireDaySwitch(expanded: Bool, isSecondSectionExpanded: Bool) {
        let cellType = BaseSettingsRightSwitchTableViewCell.self
        let indexPath = isSecondSectionExpanded ? IndexPath(row: 6, section: 1) : IndexPath(row: 0, section: 1)
        
        guard let entireDayCell = tableView.getCell(of: cellType, at: indexPath),
            let entireDaySwitch = entireDayCell.accessoryView as? UISwitch else {
            XCTFail("Cannot obtain switch")
            return
        }
        entireDaySwitch.isOn = expanded
        entireDaySwitch.sendActions(for: .valueChanged)
    }
    
    private func getPicker(_ tableView: UITableView, at indexPath: IndexPath) -> PickerView? {
        let cellType = PickerExpandableTableViewCell.self
        guard let pickerCell = tableView.getCell(of: cellType, at: indexPath) else {
            XCTFail("Cannot obtain picker cell")
            return nil
        }
        
        pickerCell.togglePickerVisibility()
        
        guard let stackView = pickerCell.contentView.subviews.compactMap({ $0 as? UIStackView }).first,
            let picker = stackView.arrangedSubviews.first as? PickerView else {
            XCTFail("Cannot obtain picker")
            return nil
        }
        
        return picker
    }
}

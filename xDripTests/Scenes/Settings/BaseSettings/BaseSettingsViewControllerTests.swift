//
//  BaseSettingsViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable function_body_length
// swiftlint:disable implicitly_unwrapped_optional

final class BaseSettingsViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: BaseSettingsViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupBaseSettingsViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupBaseSettingsViewController() {
        sut = BaseSettingsViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    func testTableViewConfigure() {
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssert(sut.tableView(tableView, heightForHeaderInSection: 0) == 40.0)
        
        var tableViewStyle = UITableView.Style.grouped
        if #available(iOS 13.0, *) {
            tableViewStyle = .insetGrouped
        }
        
        XCTAssert(sut.tableViewStyle == tableViewStyle)
    }
    
    func testEmptyViewModel() {
        loadView()
        
        sut.update(with: BaseSettings.ViewModel(sections: []))
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssert(sut.numberOfSections(in: tableView) == 0)
    }
    
    func testAnimatedUpdate() {
        loadView()
        
        sut.update(with: BaseSettings.ViewModel(sections: []))
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssert(sut.numberOfSections(in: tableView) == 0)
        
        let normalCells: [BaseSettings.Cell] = [
            .disclosure(mainText: "", detailText: nil, selectionHandler: {}),
            .pickerExpandable(mainText: "", detailText: nil, picker: CustomDatePicker()),
            .rightSwitch(text: "", isSwitchOn: false, switchHandler: { _ in }),
            .textInput(mainText: "", detailText: nil, placeholder: nil, textChangedHandler: { _ in }),
            .volumeSlider(value: 0.0, changeHandler: { _ in })
        ]
        
        let normalSection = BaseSettings.Section.normal(
            cells: normalCells,
            header: "normal header",
            footer: "normal footer"
        )
        
        let viewModel = BaseSettings.ViewModel(sections: [normalSection])
        
        sut.update(with: viewModel, animated: true)
        
        XCTAssert(tableView.numberOfSections == 1)
        XCTAssert(tableView.numberOfRows(inSection: 0) == 5)
    }
    
    func testViewWillAppear() {
        let normalCells: [BaseSettings.Cell] = [
            .disclosure(mainText: "", detailText: nil, selectionHandler: {}),
            .pickerExpandable(mainText: "", detailText: nil, picker: CustomDatePicker()),
            .rightSwitch(text: "", isSwitchOn: false, switchHandler: { _ in }),
            .textInput(mainText: "", detailText: nil, placeholder: nil, textChangedHandler: { _ in }),
            .volumeSlider(value: 0.0, changeHandler: { _ in })
        ]
        
        let normalSection = BaseSettings.Section.normal(
            cells: normalCells,
            header: "normal header",
            footer: "normal footer"
        )
        
        let viewModel = BaseSettings.ViewModel(sections: [normalSection])
        
        loadView()
        
        sut.update(with: viewModel)
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        // When
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        // Then
        XCTAssert(tableView.indexPathForSelectedRow == IndexPath(row: 0, section: 0))
        
        // When
        sut.viewWillAppear(true)
        // Then
        XCTAssert(tableView.indexPathForSelectedRow == nil)
    }
    
    func testInitWithCoder() {
        let sut = UIStoryboard(
            name: "BaseSettingsViewControllerCoderTest",
            bundle: Bundle(for: BaseSettingsViewControllerCoderTest.self)
        ).instantiateViewController(
            withIdentifier: "BaseSettingsViewControllerCoderTest"
        ) as? BaseSettingsViewControllerCoderTest
        
        XCTAssertNotNil(sut)
    }
    
    func testUpdate() {
        let normalCells: [BaseSettings.Cell] = [
            .disclosure(mainText: "", detailText: nil, selectionHandler: {}),
            .pickerExpandable(mainText: "", detailText: nil, picker: CustomDatePicker()),
            .rightSwitch(text: "", isSwitchOn: false, switchHandler: { _ in }),
            .textInput(mainText: "", detailText: nil, placeholder: nil, textChangedHandler: { _ in }),
            .volumeSlider(value: 0.0, changeHandler: { _ in })
        ]
        
        let normalSection = BaseSettings.Section.normal(
            cells: normalCells,
            header: "normal header",
            footer: "normal footer"
        )
        
        let singleCells = ["1", "2", "3"]
        let singleSelection = BaseSettings.Section.singleSelection(
            cells: singleCells,
            selectedIndex: 0,
            header: "single header",
            footer: "single footer",
            selectionHandler: { _ in }
        )
        
        let anotherSingleSection = BaseSettings.Section.singleSelection(
            cells: ["1"],
            selectedIndex: 0,
            header: nil,
            footer: nil,
            selectionHandler: { _ in }
        )
        
        let viewModel = BaseSettings.ViewModel(sections: [normalSection, singleSelection, anotherSingleSection])
        
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        // When
        sut.update(with: viewModel)
        // Then
        XCTAssert(sut.numberOfSections(in: tableView) == 3)
        XCTAssert(sut.tableView(tableView, numberOfRowsInSection: 0) == 5)
        XCTAssert(sut.tableView(tableView, numberOfRowsInSection: 1) == 3)
        XCTAssert(sut.tableView(tableView, numberOfRowsInSection: 2) == 1)
        
        XCTAssert(sut.tableView(tableView, titleForHeaderInSection: 0) == "normal header")
        XCTAssert(sut.tableView(tableView, titleForHeaderInSection: 1) == "single header")
        XCTAssertNil(sut.tableView(tableView, titleForHeaderInSection: 2))
        
        XCTAssert(sut.tableView(tableView, titleForFooterInSection: 0) == "normal footer")
        XCTAssert(sut.tableView(tableView, titleForFooterInSection: 1) == "single footer")
        XCTAssertNil(sut.tableView(tableView, titleForFooterInSection: 2))
        
        XCTAssertNil(sut.tableView(tableView, viewForHeaderInSection: 0))
        XCTAssertNil(sut.tableView(tableView, viewForHeaderInSection: 1))
        XCTAssertNotNil(sut.tableView(tableView, viewForHeaderInSection: 2))
        
        // When
        var cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        // Then
        XCTAssert(cell is BaseSettingsDisclosureCell)
        
        // When
        cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        // Then
        XCTAssert(cell is PickerExpandableTableViewCell)
        
        // When
        cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0))
        // Then
        XCTAssert(cell is BaseSettingsRightSwitchTableViewCell)
        
        // When
        cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 3, section: 0))
        // Then
        XCTAssert(cell is BaseSettingsTextInputTableViewCell)
        
        // When
        cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 4, section: 0))
        // Then
        XCTAssert(cell is BaseSettingsVolumeSliderTableViewCell)
        
        // When
        cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
        // Then
        XCTAssert(cell is BaseSettingsSingleSelectionTableViewCell)
        
        // When
        sut.update(with: BaseSettings.ViewModel(sections: []))
        // Then
        XCTAssert(sut.numberOfSections(in: tableView) == 0)
    }
    
    func testDidSelect() {
        var singleSelectionHandlerCalled = false
        var disclosureSelectionHandlerCalled = false
        
        let normalCells: [BaseSettings.Cell] = [
            .disclosure(mainText: "", detailText: nil, selectionHandler: {
                disclosureSelectionHandlerCalled = true
            })
        ]
        
        let singleCells = ["1", "2"]
        
        let viewModel = BaseSettings.ViewModel(
            sections: [
                .normal(
                    cells: normalCells,
                    header: nil,
                    footer: nil
                ),
                .singleSelection(
                    cells: singleCells,
                    selectedIndex: 0,
                    header: nil,
                    footer: nil,
                    selectionHandler: { _ in
                        singleSelectionHandlerCalled = true
                    }
                )
            ]
        )
        
        loadView()
        
        sut.update(with: viewModel)
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        // When
        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(disclosureSelectionHandlerCalled)
        
        // When
        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 1))
        // Then
        XCTAssertTrue(singleSelectionHandlerCalled)
    }
}

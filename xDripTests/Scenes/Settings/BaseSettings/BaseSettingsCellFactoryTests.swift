//
//  BaseSettingsCellFactoryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BaseSettingsCellFactoryTests: XCTestCase {
    
    let tableView = UITableView()
    let sut = BaseSettingsCellFactory()
    
    override func setUp() {
        super.setUp()
        
        sut.tableView = tableView
        
        tableView.registerNib(type: BaseSettingsDisclosureCell.self)
        tableView.registerNib(type: BaseSettingsSingleSelectionTableViewCell.self)
        tableView.registerNib(type: BaseSettingsRightSwitchTableViewCell.self)
        tableView.registerNib(type: BaseSettingsVolumeSliderTableViewCell.self)
        tableView.registerNib(type: BaseSettingsPickerExpandableTableViewCell.self)
        tableView.registerNib(type: BaseSettingsTextInputTableViewCell.self)
    }
    
    func testCreateCell() {
        // When
        let disclosure = BaseSettings.Cell.disclosure(mainText: "", detailText: nil, selectionHandler: {})
        let disclosureCell = sut.createCell(ofType: disclosure, indexPath: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(disclosureCell is BaseSettingsDisclosureCell)
        
        // When
        let textInput = BaseSettings.Cell.textInput(mainText: "", detailText: nil, textChangedHandler: { _ in })
        let textInputCell = sut.createCell(ofType: textInput, indexPath: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(textInputCell is BaseSettingsTextInputTableViewCell)
        
        // When
        let rightSwitch = BaseSettings.Cell.rightSwitch(text: "", isSwitchOn: true, switchHandler: { _ in })
        let rightSwitchCell = sut.createCell(ofType: rightSwitch, indexPath: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(rightSwitchCell is BaseSettingsRightSwitchTableViewCell)
        
        // When
        let volumeSlider = BaseSettings.Cell.volumeSlider(value: 0.0, changeHandler: { _ in })
        let volumeSliderCell = sut.createCell(ofType: volumeSlider, indexPath: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(volumeSliderCell is BaseSettingsVolumeSliderTableViewCell)
        
        // When
        let pickerExpandable = BaseSettings.Cell.pickerExpandable(mainText: "", detailText: nil, picker: CustomDatePicker())
        let pickerExpandableCell = sut.createCell(ofType: pickerExpandable, indexPath: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(pickerExpandableCell is BaseSettingsPickerExpandableTableViewCell)
        
        // When
        let singleSelectionCell = sut.createSingleSelectionCell(title: "", selectedIndex: 0, indexPath: IndexPath(row: 0, section: 0))
        // Then
        XCTAssertTrue(singleSelectionCell is BaseSettingsSingleSelectionTableViewCell)
    }
}

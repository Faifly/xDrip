//
//  BaseSettingsPickerExpandableTableViewCellTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BaseSettingsPickerExpandableTableViewCellTests: XCTestCase {
    let tableView = UITableView()
    
    override func setUp() {
        super.setUp()
        
        tableView.registerNib(type: BaseSettingsPickerExpandableTableViewCell.self)
    }
    
    func testConfigure() {
        let sut = tableView.dequeueReusableCell(
            ofType: BaseSettingsPickerExpandableTableViewCell.self,
            for: IndexPath(row: 0, section: 0)
        )
        
        var date = Date()
        let picker = CustomDatePicker()
        picker.formatDate = { pickedDate in
            date = pickedDate
            return DateFormatter.localizedString(from: pickedDate, dateStyle: .short, timeStyle: .short)
        }
        
        sut.configure(mainText: "expandable cell", detailText: "test data", pickerView: picker)
        
        guard let mainTextLabel = sut.findView(with: "mainTextLabel") as? UILabel else {
            XCTFail("Cannot obtain main text label")
            return
        }
        
        XCTAssert(mainTextLabel.text == "expandable cell")
        
        guard let detailTextLabel = sut.findView(with: "detailLabel") as? UILabel else {
            XCTFail("Cannot obtain detail text label")
            return
        }
        
        XCTAssert(detailTextLabel.text == "test data")
        
        // When
        picker.sendActions(for: .valueChanged)
        let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        // Then
        XCTAssert(detailTextLabel.text == formattedDate)
    }
    
    func testTooglePicker() {
        let sut = tableView.dequeueReusableCell(
            ofType: BaseSettingsPickerExpandableTableViewCell.self,
            for: IndexPath(row: 0, section: 0)
        )
        let picker = CustomDatePicker()
        
        sut.configure(mainText: "", detailText: "", pickerView: picker)
        
        guard let stackView = sut.contentView.subviews.compactMap({ $0 as? UIStackView }).first else {
            XCTFail("Cannot obtain stack view")
            return
        }
        
        XCTAssertFalse(stackView.arrangedSubviews.contains(picker))
        
        // When
        sut.togglePickerVisivility()
        // Then
        XCTAssertTrue(stackView.arrangedSubviews.contains(picker))
        
        // When
        sut.togglePickerVisivility()
        // Then
        XCTAssertFalse(stackView.arrangedSubviews.contains(picker))
    }
}

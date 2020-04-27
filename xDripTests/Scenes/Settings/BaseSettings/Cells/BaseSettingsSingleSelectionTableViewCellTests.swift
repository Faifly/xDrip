//
//  BaseSettingsSingleSelectionTableViewCellTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BaseSettingsSingleSelectionTableViewCellTests: XCTestCase {
    
    let tableView = UITableView()
    
    override func setUp() {
        super.setUp()
        
        tableView.registerNib(type: BaseSettingsSingleSelectionTableViewCell.self)
    }
    
    func testConfigure() {
        let sut = tableView.dequeueReusableCell(ofType: BaseSettingsSingleSelectionTableViewCell.self, for: IndexPath(row: 0, section: 0))
        
        // When
        sut.configure(mainText: "test", selected: true)
        // Then
        XCTAssert(sut.textLabel?.text == "test")
        XCTAssert(sut.accessoryType == .checkmark)
        
        // When
        sut.configure(mainText: "test", selected: false)
        // Then
        XCTAssert(sut.accessoryType == .none)
    }
}

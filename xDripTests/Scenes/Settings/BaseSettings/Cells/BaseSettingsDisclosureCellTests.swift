//
//  BaseSettingsDisclosureCellTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

@testable import xDrip
import XCTest

final class BaseSettingsDisclosureCellTests: XCTestCase {
    let tableView = UITableView()
    
    override func setUp() {
        super.setUp()
        
        tableView.registerNib(type: BaseSettingsDisclosureCell.self)
    }
    
    func testConfigure() {
        let sut = tableView.dequeueReusableCell(
            ofType: BaseSettingsDisclosureCell.self,
            for: IndexPath(row: 0, section: 0)
        )
        sut.configure(
            mainText: "hello",
            detailText: "world",
            showDisclosureIndicator: true,
            detailTextColor: nil,
            isLoading: true
        )
        
        XCTAssert(sut.textLabel?.text == "hello")
        XCTAssert(sut.detailTextLabel?.text == "world")
    }
}

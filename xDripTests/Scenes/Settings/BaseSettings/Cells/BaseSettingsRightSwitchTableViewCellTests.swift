//
//  BaseSettingsRightSwitchTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BaseSettingsRightSwitchTableViewCellTests: XCTestCase {
    let tableView = UITableView()
    
    override func setUp() {
        super.setUp()
        
        tableView.registerNib(type: BaseSettingsRightSwitchTableViewCell.self)
    }
    
    func testConfigure() {
        let sut = tableView.dequeueReusableCell(
            ofType: BaseSettingsRightSwitchTableViewCell.self,
            for: IndexPath(row: 0, section: 0)
        )
        var valueChangeHandlerCalled = false
        
        sut.configure(mainText: "switch", isSwitchOn: true)
        
        sut.valueChangedHandler = { _ in
            valueChangeHandlerCalled = true
        }
        
        XCTAssert(sut.textLabel?.text == "switch")
        
        guard let switchView = sut.accessoryView as? UISwitch else {
            XCTFail("Cannot obtaint switch")
            return
        }

        // When
        switchView.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(valueChangeHandlerCalled)
    }
}

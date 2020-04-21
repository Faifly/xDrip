//
//  BaseSettingsTextInputTableViewCellTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BaseSettingsTextInputTableViewCellTests: XCTestCase {

    let tableView = UITableView()
    
    override func setUp() {
        super.setUp()
        
        tableView.registerNib(type: BaseSettingsTextInputTableViewCell.self)
    }
    
    func testConfigure() {
        let sut = tableView.dequeueReusableCell(ofType: BaseSettingsTextInputTableViewCell.self, for: IndexPath(row: 0, section: 0))
        
        var string = ""
        var textChangeHandlerCalled = false
        
        sut.configure(mainText: "main", detailText: "placeholder") { str in
            string = str ?? ""
            textChangeHandlerCalled = true
        }
        
        guard let mainTextLabel = sut.findView(with: "mainTextLabel") as? UILabel else {
            XCTFail("Cannot obtain main text label")
            return
        }
        
        XCTAssert(mainTextLabel.text == "main")
        
        guard let textField = sut.findView(with: "textField") as? UITextField else {
            XCTFail("Cannot obtain text field")
            return
        }
        
        XCTAssert(textField.placeholder == "placeholder")
        
        // When
        textField.text = "Hello, World!"
        textField.sendActions(for: .editingChanged)
        // Then
        XCTAssertTrue(textChangeHandlerCalled)
        XCTAssert(string == "Hello, World!")
    }
}

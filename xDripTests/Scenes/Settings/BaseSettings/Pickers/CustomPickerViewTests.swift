//
//  CustomPickerViewTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable implicitly_unwrapped_optional

final class CustomPickerViewTests: XCTestCase {
    var sut: CustomPickerView!
    var valueChangedHandlerCalled = false
    var formattedString = ""

    override func setUp() {
        super.setUp()
        
        let data = [
            ["1", "2", "3"],
            ["1", "2", "3"],
            ["1", "2", "3"]
        ]
        
        sut = CustomPickerView(data: data)
        sut.reloadAllComponents()
        
        sut.formatValues = { values in
            guard values.count == 3 else { return "" }
            return "\(values[0]).\(values[1]) / \(values[2])"
        }
        
        sut.onValueChanged = { str in
            self.valueChangedHandlerCalled = true
            self.formattedString = str ?? ""
        }
    }

    func testValueChanged() {
        // When
        sut.selectRow(1, inComponent: 1, animated: false)
        sut.pickerView(sut, didSelectRow: 1, inComponent: 1)
        
        // Then
        XCTAssertTrue(valueChangedHandlerCalled)
        XCTAssert(formattedString == "1.2 / 1")
    }
}

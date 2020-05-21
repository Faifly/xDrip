//
//  CustomDatePickerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable implicitly_unwrapped_optional

final class CustomDatePickerTests: XCTestCase {    
    var sut: CustomDatePicker!
    var valueChangedHandlerCalled = false
    var formattedString = ""
    var date = Date()

    override func setUp() {
        super.setUp()
        
        sut = CustomDatePicker()
        
        sut.formatDate = { date in
            self.date = date
            return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        }
        
        sut.onValueChanged = { str in
            self.valueChangedHandlerCalled = true
            self.formattedString = str ?? ""
        }
    }

    func testValueChanged() {
        // When
        sut.sendActions(for: .valueChanged)
        
        // Then
        XCTAssertTrue(valueChangedHandlerCalled)
        
        let strDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        XCTAssert(strDate == formattedString)
    }
}

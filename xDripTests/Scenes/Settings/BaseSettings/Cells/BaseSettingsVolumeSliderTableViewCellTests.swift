//
//  BaseSettingsVolumeSliderCellTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BaseSettingsVolumeSliderTableViewCellTests: XCTestCase {
    let tableView = UITableView()
    
    override func setUp() {
        super.setUp()
        
        tableView.registerNib(type: BaseSettingsVolumeSliderTableViewCell.self)
    }
    
    func testConfigure() {
        let sut = tableView.dequeueReusableCell(
            ofType: BaseSettingsVolumeSliderTableViewCell.self,
            for: IndexPath(row: 0, section: 0)
        )
        var valueChangedHandlerCalled = false
        
        sut.configure(value: 0.5)
        sut.onSliderValueChanged = { _ in
            valueChangedHandlerCalled = true
        }
        
        guard let slider = sut.contentView.subviews.compactMap({ $0 as? UISlider }).first else {
            XCTFail("Cannot obtain slider")
            return
        }
        
        XCTAssert(slider.value == 0.5)
        
        // When
        slider.sendActions(for: .valueChanged)
        // Then
        XCTAssertTrue(valueChangedHandlerCalled)
    }
}

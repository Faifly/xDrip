//
//  BaseSettingsModelsTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BaseSettingsModelsTests: XCTestCase {
    func testSections() {
        var normalCells = [BaseSettings.Cell]()
        
        for _ in 1 ... 5 {
            normalCells.append(
                .disclosure(
                    mainText: "",
                    detailText: nil,
                    selectionHandler: {}
                )
            )
        }
        
        let normalSection = BaseSettings.Section.normal(
            cells: normalCells,
            header: "header",
            footer: "footer"
        )
        
        XCTAssert(normalSection.rowsCount == 5)
        XCTAssert(normalSection.header == "header")
        XCTAssert(normalSection.footer == "footer")
        
        let singleSelectionCells = ["1", "2", "3", "4", "5"]
        
        let singleSelection = BaseSettings.Section.singleSelection(
            cells: singleSelectionCells,
            selectedIndex: 0,
            header: "header",
            footer: "footer",
            selectionHandler: { _ in }
        )
        
        XCTAssert(singleSelection.rowsCount == 5)
        XCTAssert(singleSelection.header == "header")
        XCTAssert(singleSelection.footer == "footer")
    }
}

//
//  UIColor+Colors_Tests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 23.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

class UIColor_Colors_Tests: XCTestCase {
    func testColors() {
        XCTAssert(UIColor.Colors.tabBarBackground.rawValue == "tabBarBackground")
        _ = UIColor.tabBarBackgroundColor
        
        XCTAssert(UIColor.Colors.tabBarBlue.rawValue == "tabBarBlue")
        _ = UIColor.tabBarBlueColor
        
        XCTAssert(UIColor.Colors.tabBarGray.rawValue == "tabBarGray")
        _ = UIColor.tabBarGrayColor
        
        XCTAssert(UIColor.Colors.tabBarGreen.rawValue == "tabBarGreen")
        _ = UIColor.tabBarGreenColor
        
        XCTAssert(UIColor.Colors.tabBarOrange.rawValue == "tabBarOrange")
        _ = UIColor.tabBarOrangeColor
        
        XCTAssert(UIColor.Colors.tabBarRed.rawValue == "tabBarRed")
        _ = UIColor.tabBarRedColor
        
        XCTAssert(UIColor.Colors.lastScanDateTextColor.rawValue == "lastScanDateTextColor")
        _ = UIColor.lastScanDateTextColor
        
        // Given
        let diffTextColor: UIColor = .diffTextColor
        let chartValueNormal: UIColor = .chartValueNormal
        // When
        let comparisonResult = diffTextColor.isEqual(chartValueNormal)
        // Then
        XCTAssert(comparisonResult)
    }
    
    func testColorForSeverityLevel() {
        let normalColor = UIColor.colorForSeverityLevel(.normal)
        let abnormalColor = UIColor.colorForSeverityLevel(.abnormal)
        let criticalColor = UIColor.colorForSeverityLevel(.critical)

        XCTAssert(normalColor.isEqual(UIColor.chartValueNormal))
        XCTAssert(abnormalColor.isEqual(UIColor.chartValueAbnormal))
        XCTAssert(criticalColor.isEqual(UIColor.chartValueCritical))
    }
}

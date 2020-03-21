//
//  GlucoseUnitTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class GlucoseUnitTests: XCTestCase {
    func testDefaultValue() {
        XCTAssertTrue(GlucoseUnit.default == .mgDl)
    }
    
    func testConvertion() {
        // mg/dl to mmol/l
        XCTAssertTrue(abs(GlucoseUnit.mgDl.convertToAnother(0.0) - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseUnit.mgDl.convertToAnother(1.0) - 0.0554994394556615) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseUnit.mgDl.convertToAnother(1.33) - 0.0738142544760298) <= .ulpOfOne)
        
        // mmol/l to mg/dl
        XCTAssertTrue(abs(GlucoseUnit.mmolL.convertToAnother(0.0) - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseUnit.mmolL.convertToAnother(1.0) - 18.0182) <= .ulpOfOne)
        XCTAssertTrue(abs(GlucoseUnit.mmolL.convertToAnother(1.33) - 23.964206) <= .ulpOfOne)
    }
}

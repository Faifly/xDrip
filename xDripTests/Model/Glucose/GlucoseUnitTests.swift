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
        XCTAssertTrue(GlucoseUnit.mgDl.convertToAnother(0.0) ~ 0.0)
        XCTAssertTrue(GlucoseUnit.mgDl.convertToAnother(1.0) ~ 0.0554994394556615)
        XCTAssertTrue(GlucoseUnit.mgDl.convertToAnother(1.33) ~ 0.0738142544760298)
        
        // mmol/l to mg/dl
        XCTAssertTrue(GlucoseUnit.mmolL.convertToAnother(0.0) ~ 0.0)
        XCTAssertTrue(GlucoseUnit.mmolL.convertToAnother(1.0) ~ 18.0182)
        XCTAssertTrue(GlucoseUnit.mmolL.convertToAnother(1.33) ~ 23.964206)
    }
}

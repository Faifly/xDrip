//
//  GlucoseCurrentInfoViewTests.swift
//  xDripTests
//
//  Created by Dmitry on 6/25/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

@testable import xDrip
import XCTest

final class GlucoseCurrentInfoViewTests: XCTestCase {
    var sut: GlucoseCurrentInfoView?
    
    override func setUp() {
        super.setUp()
        sut = GlucoseCurrentInfoView.instantiate()
    }
    
    func testGlucoseCurrentInfoViewSetup() throws {
        let view = try XCTUnwrap(sut)
        // Given
        let viewModel = Home.GlucoseCurrentInfo.ViewModel(
            glucoseIntValue: "glucoseIntValue",
            glucoseDecimalValue: "glucoseDecimalValue",
            slopeValue: "slopeValue",
            lastScanDate: "lastScanDate",
            difValue: "difValue",
            severityColor: .green)
        
        // When
        view.setup(with: viewModel)
        // Then
        let mirror = GlucoseCurrentInfoViewMirror(view: view)
        XCTAssertEqual(mirror.glucoseIntValueLabel?.text, "glucoseIntValue")
        XCTAssertEqual(mirror.glucoseIntValueLabel?.textColor, .green)
        XCTAssertEqual(mirror.glucoseDecimalValueLablel?.text, ". glucoseDecimalValue")
        XCTAssertEqual(mirror.glucoseDecimalValueLablel?.textColor, .green)
        XCTAssertEqual(mirror.slopeArrowLabel?.text, "slopeValue")
        XCTAssertEqual(mirror.slopeArrowLabel?.textColor, .green)
        XCTAssertEqual(mirror.lastScanTitleLabel?.text, "home_last_scan_title".localized)
        XCTAssertEqual(mirror.lastScanTitleLabel?.textColor, .lastScanDateTextColor)
        XCTAssertEqual(mirror.lastScanValueLabel?.text, "- lastScanDate")
        XCTAssertEqual(mirror.difTitleLabel?.text, "home_last_diff_title".localized)
        XCTAssertEqual(mirror.difTitleLabel?.textColor, .diffTextColor)
        XCTAssertEqual(mirror.difValueLabel?.text, "- difValue")
    }
}

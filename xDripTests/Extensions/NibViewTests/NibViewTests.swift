//
//  NibViewTests.swift
//  xDripTests
//
//  Created by Dmitry on 6/25/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

@testable import xDrip
import XCTest

final class NibViewTests: XCTestCase {
    func testNibView() throws {
        let view = GlucoseCurrentInfoView.instantiate()
        let glucoseCurrentInfoView = try XCTUnwrap(view as? GlucoseCurrentInfoView)
        
        let mirror = GlucoseCurrentInfoViewMirror(view: glucoseCurrentInfoView)
        XCTAssertNotNil(mirror.glucoseIntValueLabel)
        XCTAssertNotNil(mirror.glucoseDecimalValueLablel)
        XCTAssertNotNil(mirror.slopeArrowLabel)
        XCTAssertNotNil(mirror.lastScanTitleLabel)
        XCTAssertNotNil(mirror.lastScanValueLabel)
        XCTAssertNotNil(mirror.difTitleLabel)
        XCTAssertNotNil(mirror.difValueLabel)
        
        let viewController = HomeViewController()
        viewController.loadViewIfNeeded()
        let mirror1 = HomeViewControllerMirror(viewController: viewController)
        let view1 = mirror1.glucoseCurrentInfoView
        let glucoseCurrentInfoView1 = try XCTUnwrap(view1)
    
        let mirror2 = GlucoseCurrentInfoViewMirror(view: glucoseCurrentInfoView1)
        XCTAssertNotNil(mirror2.glucoseIntValueLabel)
        XCTAssertNotNil(mirror2.glucoseDecimalValueLablel)
        XCTAssertNotNil(mirror2.slopeArrowLabel)
        XCTAssertNotNil(mirror2.lastScanTitleLabel)
        XCTAssertNotNil(mirror2.lastScanValueLabel)
        XCTAssertNotNil(mirror2.difTitleLabel)
        XCTAssertNotNil(mirror2.difValueLabel)
    }
}

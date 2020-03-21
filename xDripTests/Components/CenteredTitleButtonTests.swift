//
//  CenteredTitleButtonTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class CenteredTitleButtonTests: XCTestCase {
    func testInitWithFrame() {
        let frame = CGRect(x: 1.1, y: 2.2, width: 3.3, height: 4.4)
        let button = CenteredTitleButton(frame: frame)
        
        XCTAssertTrue(abs(button.frame.origin.x - 1.1) <= .ulpOfOne)
        XCTAssertTrue(abs(button.frame.origin.y - 2.2) <= .ulpOfOne)
        XCTAssertTrue(abs(button.frame.size.width - 3.3) <= .ulpOfOne)
        XCTAssertTrue(abs(button.frame.size.height - 4.4) <= .ulpOfOne)
        XCTAssertTrue(button.titleLabel!.textAlignment == .center)
    }
    
    func testInitWithCoder() {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.finishEncoding()
        let data = archiver.encodedData
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: data)
        
        let button = CenteredTitleButton(coder: unarchiver)!
        XCTAssertTrue(button.titleLabel!.textAlignment == .center)
    }
    
    func testTitleRect() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 50.0)
        let button = CenteredTitleButton(frame: rect)
        button.setTitle("123", for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        var titleRect = button.titleRect(forContentRect: rect)
        XCTAssertTrue(abs(titleRect.origin.x - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.origin.y - 28.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.size.width - 100.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.size.height - 22.0) <= .ulpOfOne)
        
        button.setTitle("12345", for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        titleRect = button.titleRect(forContentRect: rect)
        XCTAssertTrue(abs(titleRect.origin.x - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.origin.y - 28.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.size.width - 100.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.size.height - 22.0) <= .ulpOfOne)
        
        let image1 = UIImage(named: "icon_calibration")
        button.setImage(image1, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        titleRect = button.titleRect(forContentRect: rect)
        XCTAssertTrue(abs(titleRect.origin.x - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.origin.y - 28.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.size.width - 100.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.size.height - 22.0) <= .ulpOfOne)
        
        let image2 = UIImage(named: "icon_history")
        button.setImage(image2, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        titleRect = button.titleRect(forContentRect: rect)
        XCTAssertTrue(abs(titleRect.origin.x - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.origin.y - 28.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.size.width - 100.0) <= .ulpOfOne)
        XCTAssertTrue(abs(titleRect.size.height - 22.0) <= .ulpOfOne)
    }
    
    func testImageRect() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 50.0)
        let button = CenteredTitleButton(frame: rect)
        let image1 = UIImage(named: "icon_calibration")
        let image2 = UIImage(named: "icon_history")
        
        button.setTitle("123", for: .normal)
        button.setImage(image1, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        var imageRect = button.imageRect(forContentRect: rect)
        XCTAssertTrue(abs(imageRect.origin.x - 39.0) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.origin.y - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.size.width - 22.0) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.size.height - 22.0) <= .ulpOfOne)
        
        button.setTitle("12345", for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        imageRect = button.imageRect(forContentRect: rect)
        XCTAssertTrue(abs(imageRect.origin.x - 39.0) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.origin.y - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.size.width - 22.0) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.size.height - 22.0) <= .ulpOfOne)
        
        button.setImage(image2, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        imageRect = button.imageRect(forContentRect: rect)
        XCTAssertTrue(abs(imageRect.origin.x - 37.5) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.origin.y - 0.0) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.size.width - 25.0) <= .ulpOfOne)
        XCTAssertTrue(abs(imageRect.size.height - 22.0) <= .ulpOfOne)
    }
    
    func testIntrinsicContentSize() {
        let button = CenteredTitleButton(frame: .zero)
        let image1 = UIImage(named: "icon_calibration")
        let image2 = UIImage(named: "icon_history")
        
        var size = button.intrinsicContentSize
        XCTAssertTrue(abs(size.width - 30.0) <= .ulpOfOne)
        XCTAssertTrue(abs(size.height - 34.0) <= .ulpOfOne)
        
        button.setImage(image1, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        size = button.intrinsicContentSize
        XCTAssertTrue(abs(size.width - 22.0) <= .ulpOfOne)
        XCTAssertTrue(abs(size.height - 27.0) <= .ulpOfOne)
        
        button.setImage(image2, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        size = button.intrinsicContentSize
        XCTAssertTrue(abs(size.width - 25.0) <= .ulpOfOne)
        XCTAssertTrue(abs(size.height - 27.0) <= .ulpOfOne)
        
        button.setTitle("123", for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        size = button.intrinsicContentSize
        XCTAssertTrue(abs(size.width - 25.0) <= .ulpOfOne)
        XCTAssertTrue(abs(size.height - 48.5) <= .ulpOfOne)
    }
}

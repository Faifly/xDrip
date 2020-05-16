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
        
        XCTAssertTrue(button.frame.origin.x ~ 1.1)
        XCTAssertTrue(button.frame.origin.y ~ 2.2)
        XCTAssertTrue(button.frame.size.width ~ 3.3)
        XCTAssertTrue(button.frame.size.height ~ 4.4)
        XCTAssertTrue(button.titleLabel?.textAlignment == .center)
    }
    
    func testInitWithCoder() {
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        archiver.finishEncoding()
        let data = archiver.encodedData
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data) else {
            fatalError()
        }
        
        let button = CenteredTitleButton(coder: unarchiver)
        XCTAssertTrue(button?.titleLabel?.textAlignment == .center)
    }
    
    func testTitleRect() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 50.0)
        let button = CenteredTitleButton(frame: rect)
        button.setTitle("123", for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        var titleRect = button.titleRect(forContentRect: rect)
        XCTAssertTrue(titleRect.origin.x ~ 0.0)
        XCTAssertTrue(titleRect.origin.y ~~ 28.5)
        XCTAssertTrue(titleRect.size.width ~ 100.0)
        XCTAssertTrue(titleRect.size.height ~~ 21.5)
        
        button.setTitle("12345", for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        titleRect = button.titleRect(forContentRect: rect)
        XCTAssertTrue(titleRect.origin.x ~ 0.0)
        XCTAssertTrue(titleRect.origin.y ~~ 28.5)
        XCTAssertTrue(titleRect.size.width ~ 100.0)
        XCTAssertTrue(titleRect.size.height ~~ 21.5)
        
        let image1 = UIImage(named: "icon_calibration")
        button.setImage(image1, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        titleRect = button.titleRect(forContentRect: rect)
        XCTAssertTrue(titleRect.origin.x ~ 0.0)
        XCTAssertTrue(titleRect.origin.y ~~ 28.5)
        XCTAssertTrue(titleRect.size.width ~ 100.0)
        XCTAssertTrue(titleRect.size.height ~~ 21.5)
        
        let image2 = UIImage(named: "icon_history")
        button.setImage(image2, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        titleRect = button.titleRect(forContentRect: rect)
        XCTAssertTrue(titleRect.origin.x ~ 0.0)
        XCTAssertTrue(titleRect.origin.y ~~ 28.5)
        XCTAssertTrue(titleRect.size.width ~ 100.0)
        XCTAssertTrue(titleRect.size.height ~~ 21.5)
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
        XCTAssertTrue(imageRect.origin.x ~ 39.0)
        XCTAssertTrue(imageRect.origin.y ~ 0.0)
        XCTAssertTrue(imageRect.size.width ~ 22.0)
        XCTAssertTrue(imageRect.size.height ~ 22.0)
        
        button.setTitle("12345", for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        imageRect = button.imageRect(forContentRect: rect)
        XCTAssertTrue(imageRect.origin.x ~ 39.0)
        XCTAssertTrue(imageRect.origin.y ~ 0.0)
        XCTAssertTrue(imageRect.size.width ~ 22.0)
        XCTAssertTrue(imageRect.size.height ~ 22.0)
        
        button.setImage(image2, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        imageRect = button.imageRect(forContentRect: rect)
        XCTAssertTrue(imageRect.origin.x ~ 37.5)
        XCTAssertTrue(imageRect.origin.y ~ 0.0)
        XCTAssertTrue(imageRect.size.width ~ 25.0)
        XCTAssertTrue(imageRect.size.height ~ 22.0)
    }
    
    func testIntrinsicContentSize() {
        let button = CenteredTitleButton(frame: .zero)
        let image1 = UIImage(named: "icon_calibration")
        let image2 = UIImage(named: "icon_history")
        
        var size = button.intrinsicContentSize
        XCTAssertTrue(size.width ~ 30.0)
        XCTAssertTrue(size.height ~~ 33.5)
        
        button.setImage(image1, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        size = button.intrinsicContentSize
        XCTAssertTrue(size.width ~ 22.0)
        XCTAssertTrue(size.height ~ 27.0)
        
        button.setImage(image2, for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        size = button.intrinsicContentSize
        XCTAssertTrue(size.width ~ 25.0)
        XCTAssertTrue(size.height ~ 27.0)
        
        button.setTitle("123", for: .normal)
        button.setNeedsLayout()
        button.layoutIfNeeded()
        
        size = button.intrinsicContentSize
        XCTAssertTrue(size.width ~ 25.0)
        XCTAssertTrue(size.height ~~ 48.5)
    }
}

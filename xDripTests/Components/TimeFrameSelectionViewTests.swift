//
//  TimeFrameSelectionViewTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 23.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

class TimeFrameSelectionViewTests: XCTestCase {
    func testResizing() {
        let sut = TimeFrameSelectionView(frame: CGRect(x: 0, y: 0, width: 250, height: 30))
        let titles = ["1", "2", "3", "4", "5"]
        
        sut.config(with: titles)
        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        
        guard let stackView = sut.subviews.compactMap({ $0 as? UIStackView }).first  else {
            XCTFail("Cannot obtain value for stackView")
            return
        }
        
        guard stackView.arrangedSubviews.count == titles.count else {
            XCTFail("Expected button count: \(titles.count), found: \(stackView.arrangedSubviews.count)")
            return
        }

        guard let firstButton = stackView.arrangedSubviews[0] as? UIButton else {
            XCTFail("Cannot cast first subview to UIButton")
            return
        }

        // test button width before resize
        XCTAssert(firstButton.frame.width == sut.frame.width / CGFloat(titles.count))
        
        // resizing
        sut.bounds = CGRect(x: 0, y: 0, width: 450, height: 30)
        sut.setNeedsLayout()
        sut.layoutIfNeeded()
        
        // test after resizing
        XCTAssert(firstButton.frame.width == sut.frame.width / CGFloat(titles.count))
    }
    
    func testEvents() {
        let sut = TimeFrameSelectionView()
        let titles = ["1", "2", "3"]
        
        sut.config(with: titles)
        
        var index = 0
        sut.segmentChangedHandler = { idx in
            index = idx
        }
        
        guard let stackView = sut.subviews.compactMap({ $0 as? UIStackView }).first  else {
            XCTFail("Cannot obtain value for stackView")
            return
        }
        
        guard stackView.arrangedSubviews.count == titles.count else {
            XCTFail("Expected button count: \(titles.count), found: \(stackView.arrangedSubviews.count)")
            return
        }
        
        // get first segment button
        guard let firstButton = stackView.arrangedSubviews[0] as? UIButton else {
            XCTFail("Cannot cast first subview to UIButton")
            return
        }
        
        XCTAssert(firstButton.titleLabel!.text == "1")
        
        // when press first segment
        firstButton.sendActions(for: .touchUpInside)
        
        // then
        XCTAssert(index == 0)
        
        // get second segment button
        guard let secondButton = stackView.arrangedSubviews[1] as? UIButton else {
            XCTFail("Cannot cast second subview to UIButton")
            return
        }
        
        XCTAssert(secondButton.titleLabel!.text == "2")
        
        // when press second segment
        secondButton.sendActions(for: .touchUpInside)
        
        // then
        XCTAssert(index == 1)
        
        // get third segment button
        guard let thirdButton = stackView.arrangedSubviews[2] as? UIButton else {
            XCTFail("Cannot cast third subview to UIButton")
            return
        }
        
        XCTAssert(thirdButton.titleLabel!.text == "3")
        
        // when press third segment
        thirdButton.sendActions(for: .touchUpInside)
        
        // then
        XCTAssert(index == 2)
        
        // when press first segment
        firstButton.sendActions(for: .touchUpInside)
        
        // then
        XCTAssert(index == 0)
    }
    
    func testContentChanging() {
        let sut = TimeFrameSelectionView()
        var titles = ["1", "2", "3"]
        
        sut.config(with: titles)
        
        guard let stackView = sut.subviews.compactMap({ $0 as? UIStackView }).first  else {
            XCTFail("Cannot obtain value for stackView")
            return
        }
        
        guard stackView.arrangedSubviews.count == titles.count else {
            XCTFail("Expected button count: \(titles.count), found: \(stackView.arrangedSubviews.count)")
            return
        }
        
        // get first segment button
        guard let firstButton = stackView.arrangedSubviews[0] as? UIButton else {
            XCTFail("Cannot cast first subview to UIButton")
            return
        }
        
        XCTAssert(firstButton.titleLabel!.text == "1")
        
        titles = ["first", "second", "third", "fourth"]
        sut.config(with: titles)
        
        guard let secondStackView = sut.subviews.compactMap({ $0 as? UIStackView }).first  else {
            XCTFail("Cannot obtain value for stackView")
            return
        }
        
        guard secondStackView.arrangedSubviews.count == titles.count else {
            XCTFail("Expected button count: \(titles.count), found: \(secondStackView.arrangedSubviews.count)")
            return
        }
        
        guard let anotherFirstButton = secondStackView.arrangedSubviews[0] as? UIButton else {
            XCTFail("Cannot cast first subview to UIButton")
            return
        }
        
        XCTAssert(anotherFirstButton.titleLabel!.text == "first")
    }
    
    func testConfigWithEmptyArray() {
        let sut = TimeFrameSelectionView()
        
        sut.config(with: [])
        
        guard let stackView = sut.subviews.compactMap({ $0 as? UIStackView }).first  else {
            XCTFail("Cannot obtain value for stackView")
            return
        }
        
        XCTAssert(stackView.arrangedSubviews.count == 0)
    }
}

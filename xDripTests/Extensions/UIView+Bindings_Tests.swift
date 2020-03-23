//
//  UIView+Bindings_Tests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 23.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

class UIView_Bindings_Tests: XCTestCase {
    func testBindWithoutSuperview() {
        let view = UIView()
        
        view.bindToSuperview()
        
        XCTAssert(view.translatesAutoresizingMaskIntoConstraints == true)
    }
    
    func testBind() {
        let parentView = UIView()
        let subview = UIView()
        
        parentView.addSubview(subview)
        
        subview.bindToSuperview()
        
        XCTAssert(parentView.constraints.count == 4)
    }
}

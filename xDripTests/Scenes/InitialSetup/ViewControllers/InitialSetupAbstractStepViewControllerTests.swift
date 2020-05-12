//
//  InitialSetupAbstractStepViewController.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupAbstractStepViewControllerTests: XCTestCase {
    
    var sut =  InitialSetupAbstractStepViewController()
    
    func testInteractor() {
        XCTAssert(type(of: sut.interactor) == InitialSetupBusinessLogic?.self)
    }
}

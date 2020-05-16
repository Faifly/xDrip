//
//  EditCalibrationRouterTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class EditCalibrationRouterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: EditCalibrationRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        sut = EditCalibrationRouter()
    }
    
    private func createSpy() -> ViewControllerSpy {
        ViewControllerSpy()
    }
    
    // MARK: Test doubles
    
    final class ViewControllerSpy: EditCalibrationViewController {
    }
    
    // MARK: Tests
}

//
//  SettingsSplitViewControllerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 21.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable implicitly_unwrapped_optional

final class SettingsSplitViewControllerTests: XCTestCase {
    var sut: SettingsSplitViewController!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSettingsSplitViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsSplitViewController() {
        sut = SettingsSplitViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    func testControllerConfig() {
        let firstViewController = SettingsRootViewController()
        let secondController = SettingsUnitsViewController()
        
        sut.viewControllers = [firstViewController, secondController]
        
        loadView()
        
        XCTAssertTrue(sut.splitViewController(sut, collapseSecondary: secondController, onto: firstViewController))
        
        XCTAssertTrue(sut.preferredDisplayMode == .allVisible)
    }
}

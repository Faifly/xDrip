//
//  NightscoutCloudConfigurationRouterTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class NightscoutCloudConfigurationRouterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: NightscoutCloudConfigurationRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        sut = NightscoutCloudConfigurationRouter()
    }
    
    private func createSpy() -> ViewControllerSpy {
        return ViewControllerSpy()
    }
    
    // MARK: Test doubles
    
    final class ViewControllerSpy: UINavigationController {
        var lastPushedViewController: UIViewController?
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            lastPushedViewController = viewController
        }
    }
    
    // MARK: Tests
    
    func testRouteToExtraOptions() {
        let viewController = NightscoutCloudConfigurationViewController()
        let spy = createSpy()
        spy.viewControllers = [viewController]
        sut.viewController = viewController
        
        // When
        sut.routeToExtraOptions()
        // Then
        XCTAssertTrue(spy.lastPushedViewController is NightscoutCloudExtraOptionsViewController)
    }
}

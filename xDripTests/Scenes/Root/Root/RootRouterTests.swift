//
//  RootRouterTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class RootRouterTests: XCTestCase {
    var sut: RootRouter!
    
    override func setUp() {
        super.setUp()
        sut = RootRouter()
    }
    
    private func createSpy() -> ViewControllerSpy {
        return ViewControllerSpy()
    }
    
    // MARK: Test Doubles
    final class ViewControllerSpy: RootViewController {
        var lastPresentedViewController: UIViewController?
        
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            lastPresentedViewController = viewControllerToPresent
        }
    }
    
    // MARK: Test cases
    
    func testRouteToStats() {
        // Given
        let spy = createSpy()
        sut.viewController = spy
        
        // When
        sut.routeToStats()
        
        // Then
        let statsRoot = spy.lastPresentedViewController as! UINavigationController
        XCTAssert(statsRoot.viewControllers[0] is StatsRootViewController)
    }
    
    func testRouteToHistory() {
        // Given
        let spy = createSpy()
        sut.viewController = spy
        
        // When
        sut.routeToHistory()
        
        // Then
        let statsRoot = spy.lastPresentedViewController as! UINavigationController
        XCTAssert(statsRoot.viewControllers[0] is HistoryRootViewController)
    }
    
    func testRouteToSettings() {
        // Given
        let spy = createSpy()
        sut.viewController = spy
        
        // When
        sut.routeToSettings()
        
        // Then
        let statsRoot = spy.lastPresentedViewController as! UINavigationController
        XCTAssert(statsRoot.viewControllers[0] is SettingsRootViewController)
    }
}

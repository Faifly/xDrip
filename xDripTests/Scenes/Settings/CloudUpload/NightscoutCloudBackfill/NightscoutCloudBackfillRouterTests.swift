//
//  NightscoutCloudBackfillRouterTests.swift
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

final class NightscoutCloudBackfillRouterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: NightscoutCloudBackfillRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        sut = NightscoutCloudBackfillRouter()
    }
    
    private func createSpy() -> ViewControllerSpy {
        return ViewControllerSpy()
    }
    
    // MARK: Test doubles
    
    final class ViewControllerSpy: NightscoutCloudBackfillViewController {
        var lastPresentedViewController: UIViewController?
        
        override func present(
            _ viewControllerToPresent: UIViewController,
            animated flag: Bool,
            completion: (() -> Void)? = nil) {
            lastPresentedViewController = viewControllerToPresent
        }
    }
    
    // MARK: Tests
    
    func testPresentPopUp() {
        let spy = createSpy()
        sut.viewController = spy
        
        // When
        sut.presentPopUp()
        // Then
//        XCTAssertTrue(spy.lastPresentedViewController is PopUpViewController)
    }
}

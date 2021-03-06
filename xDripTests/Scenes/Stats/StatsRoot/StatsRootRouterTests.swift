//
//  StatsRootRouterTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class StatsRootRouterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: StatsRootRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        sut = StatsRootRouter()
    }
    
    private func createSpy() -> ViewControllerSpy {
        return ViewControllerSpy()
    }
    
    // MARK: Test doubles
    
    final class ViewControllerSpy: StatsRootViewController {
        var dismissCalled = false
        
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissCalled = true
        }
    }
    
    // MARK: Tests
    func testDismissSelf() {
        // Given
        let spy = createSpy()
        sut.viewController = spy
        
        // When
        sut.dismissSelf()
        
        // Given
        XCTAssertTrue(spy.dismissCalled)
    }
}

//
//  SettingsAlertTypesRouterTests.swift
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

final class SettingsAlertTypesRouterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsAlertTypesRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        sut = SettingsAlertTypesRouter()
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
    
    func testRouteToAlertSounds() {
        let viewController = SettingsAlertTypesViewController()
        let spy = createSpy()
        spy.viewControllers = [viewController]
        sut.viewController = viewController
        
        viewController.viewDidLoad()
        
        // When
        sut.routeToAlertSounds()
        // Then
        XCTAssertNil(spy.lastPushedViewController)
        
        // When
        if let interactor = viewController.interactor as? SettingsAlertTypesInteractor {
            sut.dataStore = interactor
        }
        sut.routeToAlertSounds()
        // Then
        XCTAssert(spy.lastPushedViewController is SettingsAlertSoundViewController)
    }
    
    func testRouteToSingleEvent() {
        let viewController = SettingsAlertTypesViewController()
        let spy = createSpy()
        spy.viewControllers = [viewController]
        sut.viewController = viewController
        
        viewController.viewDidLoad()
        
        // When
        sut.routeToSingleEvent()
        // Then
        XCTAssertNil(spy.lastPushedViewController)
        
        guard let tableView = viewController.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        // When
        if let interactor = viewController.interactor as? SettingsAlertTypesInteractor {
            sut.dataStore = interactor
            interactor.router = sut
        }
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 1))
        // Then
        XCTAssertTrue(sut.dataStore?.eventType == .fastRise)
        XCTAssertTrue(spy.lastPushedViewController is SettingsAlertSingleTypeViewController)
    }
}

//
//  EntriesListRouterTests.swift
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

final class EntriesListRouterTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: EntriesListRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        sut = EntriesListRouter()
    }
    
    private func createSpy() -> ViewControllerSpy {
        return ViewControllerSpy(
            persistenceWorker: EntriesListCarbsPersistenceWorker(),
            formattingWorker: EntriesListCarbsFormattingWorker()
        )
    }
    
    // MARK: Test doubles
    
    final class ViewControllerSpy: EntriesListViewController {
        var dismissCalled = false
        
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissCalled = true
        }
    }
    
    final class NavigationControllerSpy: UINavigationController {
        var lastPushedViewController: UIViewController?
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            lastPushedViewController = viewController
        }
    }
    
    // MARK: Tests
    
    func testDismissSelf() {
        // Given
        let spy = createSpy()
        sut.viewController = spy
        
        // When
        sut.dismissScene()
        
        // Then
        XCTAssertTrue(spy.dismissCalled)
    }
    
    func testShowEditControllerForCarbEntry() {
        let spy = NavigationControllerSpy()
        let controller = createSpy()
        sut.viewController = controller
        spy.viewControllers = [controller]
        
        sut.dataStore = controller.interactor as? EntriesListInteractor
        
        let entry = CarbEntry(amount: 0.0, foodType: nil, date: Date())
        sut.dataStore?.entry = entry
        
        sut.routeToEditEntry()
        
        guard let pushedController = spy.lastPushedViewController as? EditFoodEntryViewController else {
            XCTFail("Cannot obtain edit controller")
            return
        }
        
        XCTAssertTrue(pushedController.router?.dataStore?.mode == .edit)
        XCTAssertTrue(pushedController.router?.dataStore?.entryType == .carbs)
        XCTAssertTrue(pushedController.router?.dataStore?.carbEntry == entry)
        XCTAssertTrue(pushedController.router?.dataStore?.insulinEntry == nil)
    }
    
    func testShowEditControllerForBolusEntry() {
        let spy = NavigationControllerSpy()
        let controller = createSpy()
        sut.viewController = controller
        spy.viewControllers = [controller]
        
        sut.dataStore = controller.interactor as? EntriesListInteractor
        
        let entry = InsulinEntry(amount: 0.0, date: Date(), type: .bolus)
        sut.dataStore?.entry = entry
        
        sut.routeToEditEntry()
        
        guard let pushedController = spy.lastPushedViewController as? EditFoodEntryViewController else {
            XCTFail("Cannot obtain edit controller")
            return
        }
        
        XCTAssertTrue(pushedController.router?.dataStore?.mode == .edit)
        XCTAssertTrue(pushedController.router?.dataStore?.entryType == .bolus)
        XCTAssertTrue(pushedController.router?.dataStore?.insulinEntry == entry)
        XCTAssertTrue(pushedController.router?.dataStore?.carbEntry == nil)
    }
}

//
//  StatsRootViewControllerTests.swift
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

final class StatsRootViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: StatsRootViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupStatsRootViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupStatsRootViewController() {
        sut = StatsRootViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class StatsRootBusinessLogicSpy: StatsRootBusinessLogic {
        var doLoadCalled = false
        var cancelCalled = false
        
        func doLoad(request: StatsRoot.Load.Request) {
            doLoadCalled = true
        }
        
        func doCancel(request: StatsRoot.Cancel.Request) {
            cancelCalled = true
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = StatsRootBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let viewModel = StatsRoot.Load.ViewModel()
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
        // Then
    }
    
    func testCancelHandler() {
        // Given
        let spy = StatsRootBusinessLogicSpy()
        sut.interactor = spy
        loadView()
        
        let target = sut.navigationItem.leftBarButtonItem!.target!
        let action = sut.navigationItem.leftBarButtonItem!.action!
        
        // When
        _ = target.perform(action)
        
        // Given
        XCTAssertTrue(spy.cancelCalled)
    }
}

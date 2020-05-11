//
//  SettingsAlertSingleTypeViewControllerTests.swift
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

final class SettingsAlertSingleTypeViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsAlertSingleTypeViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSettingsAlertSingleTypeViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsAlertSingleTypeViewController() {
        sut = SettingsAlertSingleTypeViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class SettingsAlertSingleTypeBusinessLogicSpy: SettingsAlertSingleTypeBusinessLogic {
        var doLoadCalled = false
        
        func doLoad(request: SettingsAlertSingleType.Load.Request) {
            doLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = SettingsAlertSingleTypeBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let viewModel = SettingsAlertSingleType.Load.ViewModel(animated: false, title: "", tableViewModel: BaseSettings.ViewModel(sections: []))
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
        // Then
    }
}

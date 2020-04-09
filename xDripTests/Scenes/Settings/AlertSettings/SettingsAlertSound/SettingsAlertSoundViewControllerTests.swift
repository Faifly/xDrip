//
//  SettingsAlertSoundViewControllerTests.swift
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

final class SettingsAlertSoundViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: SettingsAlertSoundViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSettingsAlertSoundViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupSettingsAlertSoundViewController() {
        sut = SettingsAlertSoundViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class SettingsAlertSoundBusinessLogicSpy: SettingsAlertSoundBusinessLogic {
        var doLoadCalled = false
        
        func doLoad(request: SettingsAlertSound.Load.Request) {
            doLoadCalled = true
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = SettingsAlertSoundBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let viewModel = SettingsAlertSound.Load.ViewModel()
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
        // Then
    }
}

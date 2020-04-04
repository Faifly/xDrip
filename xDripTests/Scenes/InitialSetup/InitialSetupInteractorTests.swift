//
//  InitialSetupInteractorTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

final class InitialSetupInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: InitialSetupInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupInitialSetupInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupInitialSetupInteractor() {
        sut = InitialSetupInteractor()
    }
    
    // MARK: Test doubles
    
    final class InitialSetupPresentationLogicSpy: InitialSetupPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: InitialSetup.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class InitialSetupRoutingLogicSpy: InitialSetupRoutingLogic {
        func dismissScene() {
            
        }
        
        func showNextScene(_ viewController: UIViewController) {
            
        }
    }
    
    // MARK: Tests
    
    func testDoLoad() {
        // Given
        let spy = InitialSetupPresentationLogicSpy()
        sut.presenter = spy
        let request = InitialSetup.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
}

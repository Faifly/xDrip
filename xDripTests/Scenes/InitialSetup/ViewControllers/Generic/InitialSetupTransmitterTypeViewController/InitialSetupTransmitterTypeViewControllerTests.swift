//
//  InitialSetupTransmitterTypeViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable implicitly_unwrapped_optional
final class InitialSetupTransmitterTypeViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: InitialSetupTransmitterTypeViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupInitialSetupTransmitterTypeViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupInitialSetupTransmitterTypeViewController() {
        sut = InitialSetupTransmitterTypeViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledSelectDeviceType = false
        var deviceType: CGMDeviceType?
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) { }
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSaveNightscoutConnectionData(request: InitialSetup.SaveNightscoutCredentials.Request) { }
        func doFinishSetup(request: InitialSetup.FinishSetup.Request) { }
        
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) {
            calledSelectDeviceType = true
            deviceType = request.deviceType
        }
        
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) { }
    }
    
    func testOnDexcomG6Selected() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        loadView()
        
        let button = sut.navigationItem.rightBarButtonItem
        
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        
        // Then
        XCTAssertTrue(spy.calledSelectDeviceType)
        XCTAssert(spy.deviceType == .dexcomG6)
    }
}

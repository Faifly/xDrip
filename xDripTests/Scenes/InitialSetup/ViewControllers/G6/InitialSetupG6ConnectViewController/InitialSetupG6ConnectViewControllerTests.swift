//
//  InitialSetupG6ConnectViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable discouraged_optional_boolean
// swiftlint:disable implicitly_unwrapped_optional

final class InitialSetupG6ConnectViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: InitialSetupG6ConnectViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupInitialSetupG6ConnectViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupInitialSetupG6ConnectViewController() {
        sut = InitialSetupG6ConnectViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledCompleteSetup = false
        var moreStepsExpected: Bool?
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) {}
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        func doSaveNightscoutConnectionData(request: InitialSetup.SaveNightscoutCredentials.Request) { }
        func doFinishSetup(request: InitialSetup.FinishSetup.Request) { }
        
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) {
            calledCompleteSetup = true
            moreStepsExpected = request.moreStepsExpected
        }
    }
    
    func testOnContinueButton() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        loadView()
        
        let button = sut.navigationItem.rightBarButtonItem
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup == true)
        XCTAssert(spy.moreStepsExpected == true)
    }
    
    func testUpdate() {
        loadView()
        
        let controller = CGMController.shared
        controller.serviceDidUpdateMetadata(.firmwareVersion, value: "firmware")
        controller.serviceDidUpdateMetadata(.batteryVoltageA, value: "batteryA")
        controller.serviceDidUpdateMetadata(.batteryVoltageB, value: "batteryB")
        controller.serviceDidUpdateMetadata(.transmitterTime, value: "transmitterTime")
        controller.serviceDidUpdateMetadata(.deviceName, value: "testName")
    }
}

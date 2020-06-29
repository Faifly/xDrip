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
    var sut: InitialSetupG6ConnectViewController!
    
    override func setUp() {
        super.setUp()
        
        setupInitialSetupG6ConnectionViewController()
    }
    
    private func setupInitialSetupG6ConnectionViewController() {
        sut = InitialSetupG6ConnectViewController()
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
    
    private class InitialSetupDexcomG6ConnectionWorkerSpy: InitialSetupDexcomG6ConnectionWorkerProtocol {
        var calledStartConnectionProcess = false
        
        var onSuccessfulConnection: ((InitialSetupG6ConnectViewController.ViewModel) -> Void)?
        
        func startConnectionProcess() {
            calledStartConnectionProcess = true
            
            let viewModel = InitialSetupG6ConnectViewController.ViewModel(
                firmware: "firmware",
                batteryA: "batteryA",
                batteryB: "batteryB",
                transmitterTime: "transmitterTime",
                deviceName: "123"
            )
            
            onSuccessfulConnection?(viewModel)
        }
    }
    /*
    func testOnContinueButton() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let continueButton = sut.view.findView(with: "continueButton") as? UIButton else {
            XCTFail("Cannot obtain button")
            return
        }
        
        // When
        continueButton.sendActions(for: .touchUpInside)
        // Then
        XCTAssertTrue(spy.calledCompleteSetup == true)
        XCTAssert(spy.moreStepsExpected == true)
    }
    
    func testUpdate() {
        let view = sut.view
        
        guard let firmwareLabel = view?.findView(with: "firmwareLabel") as? UILabel else {
            XCTFail("Cannot obtain firmware label")
            return
        }
        guard let batteryALabel = view?.findView(with: "batteryALabel") as? UILabel else {
            XCTFail("Cannot obtain batteryA label")
            return
        }
        guard let batteryBLabel = view?.findView(with: "batteryBLabel") as? UILabel else {
            XCTFail("Cannot obtain batteryB label")
            return
        }
        guard let transmitterTimeLabel = view?.findView(with: "transmitterTimeLabel") as? UILabel else {
            XCTFail("Cannot obtain transmitter time label")
            return
        }
        guard let continueButton = view?.findView(with: "continueButton") as? UIButton else {
            XCTFail("Cannot obtain continue button")
            return
        }
        
        XCTAssert(firmwareLabel.text == "firmware")
        XCTAssert(batteryALabel.text == "batteryA")
        XCTAssert(batteryBLabel.text == "batteryB")
        XCTAssert(transmitterTimeLabel.text == "transmitterTime")
        XCTAssert(continueButton.isEnabled == true)
    }*/
}

//
//  InitialSetupG6ConnectViewControllerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupG6ConnectViewControllerTests: XCTestCase {
    
    let sut = InitialSetupG6ConnectViewController()
    
    private class InitialSetupBusinessLogicSpy: InitialSetupBusinessLogic {
        var calledCompleteSetup = false
        var moreStepsExpected: Bool? = nil
        
        func doLoad(request: InitialSetup.Load.Request) { }
        func doBeginSetup(request: InitialSetup.BeginSetup.Request) { }
        func doSkipSetup(request: InitialSetup.SkipSetup.Request) { }
        func doSelectDeviceMode(request: InitialSetup.SelectDeviceMode.Request) {}
        func doSelectInjectionType(request: InitialSetup.SelectInjectionType.Request) { }
        func doSaveSettings(request: InitialSetup.SaveSettings.Request) { }
        func doSelectDeviceType(request: InitialSetup.SelectDevice.Request) { }
        
        func doCompleteCustomDeviceStep(request: InitialSetup.CompleteCustomDeviceStep.Request) {
            calledCompleteSetup = true
            moreStepsExpected = request.moreStepsExpected
        }
    }
    
    func testOnContinueButton() {
        let spy = InitialSetupBusinessLogicSpy()
        sut.interactor = spy
        
        guard let continueButton = sut.view.subviews.first(where: { $0.accessibilityIdentifier == "continueButton" }) as? UIButton else {
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
        let controller = CGMController.shared
        
        guard let firmwareLabel = getView(for: "firmwareLabel") as? UILabel else {
            XCTFail("Cannot obtain firmware label")
            return
        }
        guard let batteryALabel = getView(for: "batteryALabel") as? UILabel else {
            XCTFail("Cannot obtain batteryA label")
            return
        }
        guard let batteryBLabel = getView(for: "batteryBLabel") as? UILabel else {
            XCTFail("Cannot obtain batteryB label")
            return
        }
        guard let transmitterTimeLabel = getView(for: "transmitterTimeLabel") as? UILabel else {
            XCTFail("Cannot obtain transmitter time label")
            return
        }
        guard let continueButton = getView(for: "continueButton") as? UIButton else {
            XCTFail("Cannot obtain continue button")
            return
        }
        
        XCTAssert(firmwareLabel.text == "Unknown")
        XCTAssert(batteryALabel.text == "Unknown")
        XCTAssert(batteryBLabel.text == "Unknown")
        XCTAssert(transmitterTimeLabel.text == "Unknown")
        XCTAssert(continueButton.isEnabled == false)
        
        
        // When
        controller.serviceDidUpdateMetadata(.firmwareVersion, value: "firmware")
        // Then
        XCTAssert(firmwareLabel.text == "Unknown")
        XCTAssert(batteryALabel.text == "Unknown")
        XCTAssert(batteryBLabel.text == "Unknown")
        XCTAssert(transmitterTimeLabel.text == "Unknown")
        XCTAssert(continueButton.isEnabled == false)
        
        // When
        controller.serviceDidUpdateMetadata(.batteryVoltageA, value: "batteryA")
        // Then
        XCTAssert(firmwareLabel.text == "Unknown")
        XCTAssert(batteryALabel.text == "Unknown")
        XCTAssert(batteryBLabel.text == "Unknown")
        XCTAssert(transmitterTimeLabel.text == "Unknown")
        XCTAssert(continueButton.isEnabled == false)
        
        // When
        controller.serviceDidUpdateMetadata(.batteryVoltageB, value: "batteryB")
        // Then
        XCTAssert(firmwareLabel.text == "Unknown")
        XCTAssert(batteryALabel.text == "Unknown")
        XCTAssert(batteryBLabel.text == "Unknown")
        XCTAssert(transmitterTimeLabel.text == "Unknown")
        XCTAssert(continueButton.isEnabled == false)
        
        // When
        controller.serviceDidUpdateMetadata(.transmitterTime, value: "transmitterTime")
        // Then
        XCTAssert(firmwareLabel.text == "firmware")
        XCTAssert(batteryALabel.text == "batteryA")
        XCTAssert(batteryBLabel.text == "batteryB")
        XCTAssert(transmitterTimeLabel.text == "transmitterTime")
        XCTAssert(continueButton.isEnabled == true)
    }
    
    private func getView(for accessibilityID: String) -> UIView? {
        guard let view = sut.view.subviews.first(where: { $0.accessibilityIdentifier == accessibilityID }) else {
            return nil
        }
        
        return view
    }
}

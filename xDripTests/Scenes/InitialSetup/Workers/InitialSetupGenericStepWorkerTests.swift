//
//  InitialSetupGenericStepWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupGenericStepWorkerTests: XCTestCase {
    let sut = InitialSetupGenericStepWorker()
    
    func testCompleteStepForMain() {
        User.current.settings.updateDeviceMode(.default)
        
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupIntroViewController)
        
        // When
        sut.completeStep(InitialSetup.GenericStep.intro)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupDeviceModeViewController)
        
        // When
        sut.completeStep(InitialSetup.GenericStep.deviceMode)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupInjectionTypeViewController)
        
        // When
        sut.completeStep(InitialSetup.GenericStep.injectionType)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupSettingsViewController)
        
        // When
        sut.completeStep(InitialSetup.GenericStep.settings)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupTransmitterTypeViewController)
        
        // When
        sut.completeStep(InitialSetup.GenericStep.transmitterType)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() == nil)
    }
    
    func testCompleteStepForFollower() {
        User.current.settings.updateDeviceMode(.follower)
        
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupIntroViewController)
        
        // When
        sut.completeStep(InitialSetup.GenericStep.intro)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupDeviceModeViewController)
        
        // When
        sut.completeStep(InitialSetup.GenericStep.deviceMode)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupInjectionTypeViewController)
    }
}

//
//  InitialSetupG6StepWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupG6StepWorkerTests: XCTestCase {
    let sut = InitialSetupG6StepWorker()
    
    func testInitConnectionStep() {
        // When
        sut.initConnectionStep()
        
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupG6ConnectViewController)
    }
    
    func testCompleteStep() {
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupG6DeviceIDViewController)
        
        // When
        sut.completeStep(InitialSetupG6Step.deviceID)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupG6SensorAgeViewController)
        
        // When
        sut.completeStep(InitialSetupG6Step.sensorAge)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupG6ConnectViewController)
        
        // When
        sut.completeStep(InitialSetupG6Step.connect)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupG6WarmUpViewController)
        
        // When
        sut.completeStep(InitialSetupG6Step.warmUp)
        // Then
        XCTAssertTrue(sut.nextStep?.createViewController() is InitialSetupG6WarmUpViewController)
    }
}

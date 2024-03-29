//
//  InitialSetupDexcomG6ConnectionWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupDexcomG6ConnectionWorkerTests: XCTestCase {    
    let sut = InitialSetupDexcomG6ConnectionWorker()
    var calledSuccessfulConnectionHandler = false
    
    override func setUp() {
        super.setUp()
        
        sut.onSuccessfulConnection = { _ in
            self.calledSuccessfulConnectionHandler = true
        }
    }
    
    func testStartConnection() {
        // When
        sut.startConnectionProcess()
        
        // Then
        XCTAssertTrue(CGMDevice.current.isSetupInProgress)
        #if targetEnvironment(simulator)
        XCTAssertTrue(CGMController.shared.service is MockedBluetoothService)
        #else
        XCTAssertTrue(CGMController.shared.service is DexcomG6BluetoothService)
        #endif
    }
    
    func testHandleSuccessfulConnection() {
        // When
        sut.startConnectionProcess()
        
        let controller = CGMController.shared
        controller.serviceDidUpdateMetadata(.firmwareVersion, value: "123")
        XCTAssert(calledSuccessfulConnectionHandler == false)
        
        controller.serviceDidUpdateMetadata(.batteryVoltageA, value: "90")
        XCTAssert(calledSuccessfulConnectionHandler == false)
        
        controller.serviceDidUpdateMetadata(.batteryVoltageB, value: "78")
        XCTAssert(calledSuccessfulConnectionHandler == false)
        
        controller.serviceDidUpdateMetadata(.transmitterTime, value: "123123123")
        XCTAssert(calledSuccessfulConnectionHandler == false)
        
        controller.serviceDidUpdateMetadata(.deviceName, value: "321")
        XCTAssert(calledSuccessfulConnectionHandler == true)
    }
}

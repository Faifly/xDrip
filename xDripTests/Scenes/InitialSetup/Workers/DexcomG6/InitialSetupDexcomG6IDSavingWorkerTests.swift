//
//  InitialSetupDexcomG6IDSavingWorkerTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class InitialSetupDexcomG6IDSavingWorkerTests: XCTestCase {
    let sut = DexcomG6SerialSavingWorker()
    
    func testValidate() {
        // When
        var identifier: String?
        // Then
        XCTAssert(sut.validate(identifier) == false)
        
        // When
        identifier = "abcdef"
        // Then
        XCTAssert(sut.validate(identifier) == false)
        
        // When
        identifier = "123456"
        // Then
        XCTAssert(sut.validate(identifier) == true)
        
        // When
        identifier = "ABC123"
        // Then
        XCTAssert(sut.validate(identifier) == true)
        
        // When
        identifier = "ABCDEF"
        // Then
        XCTAssert(sut.validate(identifier) == true)
        
        // When
        identifier = "1234567"
        // Then
        XCTAssert(sut.validate(identifier) == false)
        
        // When
        identifier = "12345"
        // Then
        XCTAssert(sut.validate(identifier) == false)
    }
    
    func testSave() {
        let identifier = "123456"
        
        guard sut.validate(identifier) else {
            XCTFail("ID not valid")
            return
        }
        
        // When
        sut.saveID(identifier)
        
        // Then
        XCTAssert(CGMDevice.current.metadata(ofType: .serialNumber) != nil)
    }
}

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
    
    let sut = InitialSetupDexcomG6IDSavingWorker()
    
    func testValidate() {
        // When
        var id: String? = nil
        // Then
        XCTAssert(sut.validate(id) == false)
        
        // When
        id = "abcdef"
        // Then
        XCTAssert(sut.validate(id) == false)
        
        // When
        id = "123456"
        // Then
        XCTAssert(sut.validate(id) == true)
        
        // When
        id = "ABC123"
        // Then
        XCTAssert(sut.validate(id) == true)
        
        // When
        id = "ABCDEF"
        // Then
        XCTAssert(sut.validate(id) == true)
        
        // When
        id = "1234567"
        // Then
        XCTAssert(sut.validate(id) == false)
        
        // When
        id = "12345"
        // Then
        XCTAssert(sut.validate(id) == false)
    }
    
    func testSave() {
        let id = "123456"
        
        guard sut.validate(id) else {
            XCTFail("ID not valid")
            return
        }
        
        // When
        sut.saveID(id)
        
        // Then
        XCTAssert(CGMDevice.current.metadata(ofType: .serialNumber) != nil)
    }
}

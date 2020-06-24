//
//  HomeGlucoseFormattingWorkerTests.swift
//  xDripTests
//
//  Created by Dmitry on 6/22/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

import XCTest
@testable import xDrip

final class HomeGlucoseFormattingWorkerTests: XCTestCase {
    let sut = HomeGlucoseFormattingWorker()
    
    override func setUp() {
        super.setUp()
    }
    
    func testFormatEntry() {
        // Given
        let reading: GlucoseReading? = nil
        // When
        let formattedEntry = sut.formatEntry(reading)
        // Then
        XCTAssertTrue(formattedEntry.glucoseIntValue == "-")
        XCTAssertTrue(formattedEntry.glucoseDecimalValue == "-")
        XCTAssertTrue(formattedEntry.lastScanDate == "--")
        XCTAssertTrue(formattedEntry.difValue == "--")
        
        // Given
        let reading1 = GlucoseReading()
        reading1.setValue(Date() + .secondsPerDay, forKey: "date")
        reading1.setValue(0.0, forKey: "filteredCalculatedValue")
        reading1.setValue(-5.5, forKey: "calculatedValueSlope")
        // When
        let formattedEntry1 = sut.formatEntry(reading1)
        // Then
        XCTAssertTrue(formattedEntry1.glucoseIntValue == "0")
        XCTAssertTrue(formattedEntry1.glucoseDecimalValue == "0")
        XCTAssertTrue(!formattedEntry1.lastScanDate.isEmpty)
        XCTAssertTrue(formattedEntry1.difValue.contains("-5.5 "))
        
        // Given
        let reading2 = GlucoseReading()
        reading2.setValue(Date(), forKey: "date")
        reading2.setValue(12345.193456, forKey: "filteredCalculatedValue")
        reading2.setValue(0.012345, forKey: "calculatedValueSlope")
        // When
        let formattedEntry2 = sut.formatEntry(reading2)
        // Then
        XCTAssertTrue(formattedEntry2.glucoseIntValue == "12345")
        XCTAssertTrue(formattedEntry2.glucoseDecimalValue == "2")
        XCTAssertTrue(!formattedEntry2.lastScanDate.isEmpty)
        XCTAssertTrue(formattedEntry2.difValue.contains("0.01 "))
        
        // Given
        let reading3 = GlucoseReading()
        // When
        let formattedEntry3 = sut.formatEntry(reading3)
        // Then
        XCTAssertTrue(!formattedEntry3.lastScanDate.isEmpty)
    }
    
    func testSlopeToArrowSymbol() {
        // Given
        let reading: GlucoseReading? = nil
        // When
        let formattedEntry = sut.formatEntry(reading)
        // Then
        XCTAssertTrue(formattedEntry.slopeValue == "-")
        
        // Given
        let reading1 = GlucoseReading()
        reading1.setValue(-3.6, forKey: "b")
        // When
        let formattedEntry1 = sut.formatEntry(reading1)
        // Then
        XCTAssertTrue(formattedEntry1.slopeValue == "\u{21ca}")
        
        // Given
        let reading2 = GlucoseReading()
        reading2.setValue(3.6, forKey: "b")
        // When
        let formattedEntry2 = sut.formatEntry(reading2)
        // Then
        XCTAssertTrue(formattedEntry2.slopeValue == "\u{21c8}")
        
        // Given
        let reading4 = GlucoseReading()
        reading4.setValue(-2.1, forKey: "b")
        // When
        let formattedEntry4 = sut.formatEntry(reading4)
        // Then
        XCTAssertTrue(formattedEntry4.slopeValue == "\u{2193}")
        
        // Given
        let reading5 = GlucoseReading()
        reading5.setValue(-1.1, forKey: "b")
        // When
        let formattedEntry5 = sut.formatEntry(reading5)
        // Then
        XCTAssertTrue(formattedEntry5.slopeValue == "\u{2198}")
        
        // Given
        let reading6 = GlucoseReading()
        reading4.setValue(0.9, forKey: "b")
        // When
        let formattedEntry6 = sut.formatEntry(reading6)
        // Then
        XCTAssertTrue(formattedEntry6.slopeValue == "\u{2192}")
        
        // Given
        let reading7 = GlucoseReading()
        reading7.setValue(1.9, forKey: "b")
        // When
        let formattedEntry7 = sut.formatEntry(reading7)
        // Then
        XCTAssertTrue(formattedEntry7.slopeValue == "\u{2197}")
        
        // Given
        let reading8 = GlucoseReading()
        reading8.setValue(3.4, forKey: "b")
        // When
        let formattedEntry8 = sut.formatEntry(reading8)
        // Then
        XCTAssertTrue(formattedEntry8.slopeValue == "\u{2191}")
    }
}

//
//  TrainingEntryTests.swift
//  xDripTests
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable force_unwrapping

final class TrainingEntryTests: AbstractRealmTest {
    func testInit() {
        let date = Date(timeIntervalSince1970: 2.0)
        let entry = TrainingEntry(duration: 1.1, intensity: .low, date: date)
        
        XCTAssertTrue(entry.duration ~ 1.1)
        XCTAssertTrue(entry.intensity == .low)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 2.0)
    }
    
    func testIntensity() {
        let entry = TrainingEntry()
        XCTAssertTrue(entry.intensity == .default)
        
        entry.update(duration: 0.0, intensity: .high, date: Date())
        XCTAssertTrue(entry.intensity == .high)
        
        entry.setValue(-1, forKey: "rawIntensity")
        XCTAssertTrue(entry.intensity == .default)
    }
    
    func testUpdating() {
        let entry = TrainingEntry(duration: 1.1, intensity: .normal, date: Date())
        
        let date = Date(timeIntervalSince1970: 3.0)
        entry.update(duration: 2.2, intensity: .high, date: date)
        
        XCTAssertTrue(entry.duration ~ 2.2)
        XCTAssertTrue(entry.intensity == .high)
        XCTAssertTrue(entry.date!.timeIntervalSince1970 ~~ 3.0)
    }
}

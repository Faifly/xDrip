//
//  BasalChartDataWorkerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 23.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

final class BasalChartDataWorkerTests: AbstractRealmTest {
    func testFetchBasalData() {
        let minimumDate = Date() - .secondsPerDay
        
        InsulinEntriesWorker.addBasalEntry(amount: 12.0, date: minimumDate + .secondsPerHour)
        InsulinEntriesWorker.addBasalEntry(amount: 24.0, date: minimumDate - .secondsPerHour)
        InsulinEntriesWorker.addBolusEntry(amount: 12.0, date: minimumDate + .secondsPerHour)
        
        let basals = BasalChartDataWorker.fetchBasalData(for: 24)
        
        XCTAssert(basals.count == 1)
    }
    
    func testGetBasalValueForDate() {
        let settings = User.current.settings
        
        settings?.addBasalRate(startTime: 0.0, units: 5.0)
        
        let minimumDate = Date() - .secondsPerHour * 2.0
        
        let calculatedValue1 = BasalChartDataWorker.getBasalValueForDate(date: minimumDate)
        XCTAssert(calculatedValue1 ~ 0.0)
        
        InsulinEntriesWorker.addBasalEntry(amount: 10.0, date: minimumDate)
        InsulinEntriesWorker.addBasalEntry(amount: 5.0, date: minimumDate + .secondsPerHour)
        
        let calculatedValue2 = BasalChartDataWorker.getBasalValueForDate(date: minimumDate - .secondsPerDay * 3.0)
        XCTAssert(calculatedValue2 ~ 0.0)
        
        let calculatedValue3 = BasalChartDataWorker.getBasalValueForDate(date: minimumDate + .secondsPerHour)
        
        XCTAssert(calculatedValue3 ~ 10.0)
    }
}

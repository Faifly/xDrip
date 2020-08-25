//
//  HomeEntriesFormattingWorkerTests.swift
//  xDripTests
//
//  Created by Dmitry on 05.08.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

import XCTest
@testable import xDrip

final class HomeEntriesFormattingWorkerTests: XCTestCase {
    let sut = HomeEntriesFormattingWorker()
    
    override func setUp() {
        super.setUp()
    }
    
    func testFormatBolusResponse() {
        // Given
        let insulinEntries = [
            InsulinEntry(amount: 62, date: Date() - 2000, type: .bolus),
            InsulinEntry(amount: 60, date: Date() - 1950, type: .bolus),
            InsulinEntry(amount: 61, date: Date(), type: .bolus)
        ]
        let insulinAbsorbtionDuration = User.current.settings.insulinActionTime
        // When
        let response = Home.BolusDataUpdate.Response(insulinData: insulinEntries, isShown: true)
        let formattedResponse = sut.formatBolusResponse(response)
        // Then
        let entries = formattedResponse.entries
        XCTAssert(entries.count == 9)
        XCTAssert(entries.first?.date ~~ insulinEntries.first?.date)
        XCTAssert(entries.first?.value ~ 0.0)
        XCTAssert(entries.last?.date ~~ insulinEntries.last?.date?.addingTimeInterval(insulinAbsorbtionDuration))
        XCTAssert(entries.last?.value ~ 0.0)
        XCTAssert(entries[3].date ~~ insulinEntries[1].date)
        XCTAssert(entries[3].value ~ 0.0)
        XCTAssert(entries[4].date ~~ insulinEntries[1].date)
        
        let entry = insulinEntries[1]
        let prevEntry = insulinEntries[0]
        guard let entryDate = entry.date else { return XCTFail("entryDate should not be nil.") }
        guard let prevEntryDate = prevEntry.date else { return XCTFail("prevEntryDate should not be nil.") }
        let endX = prevEntryDate.addingTimeInterval(insulinAbsorbtionDuration).timeIntervalSince1970
        let pointX = entryDate.timeIntervalSince1970
        let startX = prevEntryDate.timeIntervalSince1970
        let lastAmount = ((pointX - startX) * (0.0 - prevEntry.amount)) / (endX - startX) + prevEntry.amount
        XCTAssert(entries[4].value ~ insulinEntries[1].amount + lastAmount)
        
        // Given
        let insulinEntries1 = [InsulinEntry(amount: 62, date: Date() - 2000, type: .bolus)]
        // When
        let response1 = Home.BolusDataUpdate.Response(insulinData: insulinEntries1, isShown: true)
        let formattedResponse1 = sut.formatBolusResponse(response1)
        // Then
        let entries1 = formattedResponse1.entries
        XCTAssert(entries1.count == 3)
        XCTAssert(entries1.first?.date ~~ insulinEntries1.first?.date)
        XCTAssert(entries1.first?.value ~ 0.0)
        XCTAssert(entries1.last?.date ~~ insulinEntries1.last?.date?.addingTimeInterval(insulinAbsorbtionDuration))
        XCTAssert(entries1.last?.value ~ 0.0)
        XCTAssert(entries1[1].date ~~ insulinEntries1[0].date)
        XCTAssert(entries1[1].value ~ insulinEntries1[0].amount)
        
        // Given
        let insulinEntries2: [InsulinEntry] = []
        // When
        let response2 = Home.BolusDataUpdate.Response(insulinData: insulinEntries2, isShown: true)
        let formattedResponse2 = sut.formatBolusResponse(response2)
        // Then
        XCTAssert(formattedResponse2.entries.isEmpty)
    }
    
    func testFormatCarbsResponse() {
        // Given
        let carbsEntries = [
            CarbEntry(amount: 62, foodType: nil, date: Date() - 2000),
            CarbEntry(amount: 60, foodType: nil, date: Date())
        ]
        let carbsAbsorbtionDuration = User.current.settings.carbsAbsorptionRate
        // When
        let response = Home.CarbsDataUpdate.Response(carbsData: carbsEntries, isShown: true)
        let formattedResponse = sut.formatCarbsResponse(response)
        // Then
        let entries = formattedResponse.entries
        XCTAssert(entries.count == 6)
        XCTAssert(entries.first?.date ~~ carbsEntries.first?.date)
        XCTAssert(entries.first?.value ~ 0.0)
        XCTAssert(entries.last?.date ~~ carbsEntries.last?.date?.addingTimeInterval(carbsAbsorbtionDuration))
        XCTAssert(entries.last?.value ~ 0.0)
        
        XCTAssert(entries[3].date ~~ carbsEntries[1].date)
        XCTAssert(entries[3].value ~ 0.0)
        XCTAssert(entries[4].date ~~ carbsEntries[1].date)
//        XCTAssert(entries[4].value == carbsEntries[1].amount)
        
        // Given
        let carbsEntries1 = [CarbEntry(amount: 62, foodType: nil, date: Date() - 2000)]
        // When
        let response1 = Home.CarbsDataUpdate.Response(carbsData: carbsEntries1, isShown: true)
        let formattedResponse1 = sut.formatCarbsResponse(response1)
        // Then
        let entries1 = formattedResponse1.entries
        XCTAssert(entries1.count == 3)
        XCTAssert(entries1.first?.date ~~ carbsEntries1.first?.date)
        XCTAssert(entries1.first?.value ~ 0.0)
        XCTAssert(entries1.last?.date ~~ carbsEntries1.last?.date?.addingTimeInterval(carbsAbsorbtionDuration))
        XCTAssert(entries1.last?.value ~ 0.0)
        XCTAssert(entries1[1].date ~~ carbsEntries1[0].date)
        XCTAssert(entries1[1].value ~ carbsEntries1[0].amount)
        
        // Given
        let carbsEntries2: [CarbEntry] = [CarbEntry(amount: 0.0, foodType: nil, date: Date() - 2000)]
        // When
        let response2 = Home.CarbsDataUpdate.Response(carbsData: carbsEntries2, isShown: true)
        let formattedResponse2 = sut.formatCarbsResponse(response2)
        // Then
        XCTAssert(formattedResponse2.entries.isEmpty)
        
        // Given
        let carbsEntries3: [CarbEntry] = []
        // When
        let response3 = Home.CarbsDataUpdate.Response(carbsData: carbsEntries3, isShown: true)
        let formattedResponse3 = sut.formatCarbsResponse(response3)
        // Then
        XCTAssert(formattedResponse3.entries.isEmpty)
    }
    
    func testGetChartButtonTitle() {
        // Given
        let insulinEntries: [InsulinEntry] = []
        // When
        let response = Home.BolusDataUpdate.Response(insulinData: insulinEntries, isShown: true)
        _ = sut.formatBolusResponse(response)
        let bolusChartButtonTitle = sut.getChartButtonTitle(.bolus)
        // Then
        XCTAssert(bolusChartButtonTitle == "0.00 \(Root.EntryType.bolus.shortLabel) >")
        
        // Given
        let insulinEntries1 = [
            InsulinEntry(amount: 61, date: Date(), type: .bolus)
        ]
        // When
        let response1 = Home.BolusDataUpdate.Response(insulinData: insulinEntries1, isShown: true)
        _ = sut.formatBolusResponse(response1)
        let bolusChartButtonTitle1 = sut.getChartButtonTitle(.bolus)
        // Then
        let amoutString = String(format: "%.2f", insulinEntries1[0].amount.rounded(to: 2))
        XCTAssert(bolusChartButtonTitle1 == "\(amoutString) \(Root.EntryType.bolus.shortLabel) >")
        
        // Given
        let insulinEntries2 = [
            InsulinEntry(amount: 61, date: Date() - 500, type: .bolus),
            InsulinEntry(amount: 39, date: Date(), type: .bolus)
        ]
        // When
        let response2 = Home.BolusDataUpdate.Response(insulinData: insulinEntries2, isShown: true)
        _ = sut.formatBolusResponse(response2)
        let bolusChartButtonTitle2 = sut.getChartButtonTitle(.bolus)
        // Then
        let amount = insulinEntries2[0].amount + insulinEntries2[1].amount
        let amoutString2 = String(format: "%.2f", amount.rounded(to: 2))
        XCTAssert(bolusChartButtonTitle2 == "\(amoutString2) \(Root.EntryType.bolus.shortLabel) >")
        
        // Given
        let insulinEntries3 = [
            InsulinEntry(amount: 61, date: Date() - 3800, type: .bolus),
            InsulinEntry(amount: 39, date: Date() - 500, type: .bolus),
            InsulinEntry(amount: 50, date: Date(), type: .bolus)
        ]
        // When
        let response3 = Home.BolusDataUpdate.Response(insulinData: insulinEntries3, isShown: true)
        _ = sut.formatBolusResponse(response3)
        let bolusChartButtonTitle3 = sut.getChartButtonTitle(.bolus)
        // Then
        let insulinAbsorbtionDuration = User.current.settings.insulinActionTime
        let pointX = Date().timeIntervalSince1970 - .secondsPerHour
        guard let entryDate = insulinEntries3[0].date else { return XCTFail("entryDate should not be nil.") }
        let entry = insulinEntries3[0]
        let startX = entryDate.timeIntervalSince1970
        let entryEndDate = entryDate.addingTimeInterval(insulinAbsorbtionDuration)
        let endX = entryEndDate.timeIntervalSince1970
        let lastAmount = ((pointX - startX) * (0 - entry.amount)) / (endX - startX) + entry.amount
        let amount1 = lastAmount + insulinEntries3[1].amount + insulinEntries3[2].amount
        let amoutString3 = String(format: "%.2f", amount1.rounded(to: 2))
        XCTAssert(bolusChartButtonTitle3 == "\(amoutString3) \(Root.EntryType.bolus.shortLabel) >")
    }
}

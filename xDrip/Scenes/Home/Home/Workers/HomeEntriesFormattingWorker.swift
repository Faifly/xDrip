//
//  HomeEntriesFormattingWorker.swift
//  xDrip
//
//  Created by Dmitry on 6/26/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

struct InsulinCarbEntry: BaseHomeEntryProtocol {
    let title: String
    let buttonTitle: String
    let entries: [BaseChartEntry]
    let unit: String
    let color: UIColor
}

protocol HomeEntriesFormattingWorkerProtocol {
    func formatBolusResponse(_ response: Home.BolusDataUpdate.Response) -> InsulinCarbEntry
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> InsulinCarbEntry
}

final class HomeEntriesFormattingWorker: HomeEntriesFormattingWorkerProtocol {
    func formatBolusResponse(_ response: Home.BolusDataUpdate.Response) -> InsulinCarbEntry {
        let entries = response.insulinData
        let insulinDuration = User.current.settings.insulinActionTime
        let baseChartEntries = formatEntries(entries, absorbtionDuration: insulinDuration)
        
        for obj in baseChartEntries {
            print("obj \(obj.value) \(obj.date)")
        }
        
        return InsulinCarbEntry(title: "Active Insulin",
                                buttonTitle: "14.49" + Root.EntryType.bolus.shortLabel + ">",
                                entries: baseChartEntries,
                                unit: Root.EntryType.bolus.shortLabel,
                                color: .red)
    }
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> InsulinCarbEntry {
        let entries = response.carbsData
        let carbsDuration = User.current.settings.carbsAbsorptionRate
        let baseChartEntries = formatEntries(entries, absorbtionDuration: carbsDuration)
        
        return InsulinCarbEntry(title: "Active Carbohydrates",
                                buttonTitle: "40" + Root.EntryType.carbs.shortLabel + ">",
                                entries: baseChartEntries,
                                unit: Root.EntryType.carbs.shortLabel,
                                color: .green)
    }

    func formatEntries(_ entries: [AbstractEntryProtocol], absorbtionDuration: TimeInterval) -> [BaseChartEntry] {
        var baseChartEntries: [BaseChartEntry] = []
        for index in 0..<entries.count {
            let entry = entries[index]
            guard let entryDate = entry.date else { break }
            var entryAmount = entry.amount
            let entryEndDate = entryDate.addingTimeInterval(absorbtionDuration)
            var finalEntryAmount = 0.0
            var finalEntryDate = entryEndDate
            
            if index < entries.count - 1 {
                let nextEntry = entries[index + 1]
                guard let nextEntryDate = nextEntry.date else { break }
                if nextEntryDate < entryEndDate && nextEntry.amount > 0 {
                    let nextX = nextEntryDate.timeIntervalSince1970
                    let startX = entryDate.timeIntervalSince1970
                    let endX = entryEndDate.timeIntervalSince1970
                    finalEntryAmount = ((nextX - startX) * (0 - entry.amount)) / (endX - startX) + entry.amount
                    finalEntryDate = nextEntryDate
                }
            }
            
            if index > 0 && entryAmount > 0 {
                let prevEntry = entries[index - 1]
                guard let prevEntryDate = prevEntry.date else { break }
                let endX = prevEntryDate.addingTimeInterval(absorbtionDuration).timeIntervalSince1970
                if entryDate.timeIntervalSince1970 < endX {
                    let nextX = entryDate.timeIntervalSince1970
                    let startX = prevEntryDate.timeIntervalSince1970
                    let lastAmount = ((nextX - startX) * (0 - prevEntry.amount)) / (endX - startX) + prevEntry.amount
                    entryAmount += lastAmount
                }
            }
            
            baseChartEntries.append(BaseChartEntry(value: entryAmount, date: entry.date ?? Date()))
            baseChartEntries.append(BaseChartEntry(value: finalEntryAmount, date: finalEntryDate))
        }
        return baseChartEntries
    }
}

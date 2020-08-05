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
    let entries: [BaseChartEntry]
    let unit: String
    let color: UIColor
}

protocol HomeEntriesFormattingWorkerProtocol {
    func formatBolusResponse(_ response: Home.BolusDataUpdate.Response) -> InsulinCarbEntry
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> InsulinCarbEntry
    func getChartButtonTitle(_ entryType: Root.EntryType) -> String
    func setTimeInterval(_ localInterval: TimeInterval)
}

final class HomeEntriesFormattingWorker: HomeEntriesFormattingWorkerProtocol {
    private var timeInterval: TimeInterval = .secondsPerHour
    private var insulinEntries: [InsulinEntry] = []
    private var carbEntries: [CarbEntry] = []
    
    func formatBolusResponse(_ response: Home.BolusDataUpdate.Response) -> InsulinCarbEntry {
        insulinEntries = response.insulinData
        let insulinDuration = User.current.settings.insulinActionTime
        let baseChartEntries = formatEntries(insulinEntries, absorbtionDuration: insulinDuration)
        return InsulinCarbEntry(title: "home_active_insulin".localized,
                                entries: baseChartEntries,
                                unit: Root.EntryType.bolus.shortLabel,
                                color: .bolusChartEntry)
    }
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> InsulinCarbEntry {
        carbEntries = response.carbsData
        let carbsDuration = User.current.settings.carbsAbsorptionRate
        let baseChartEntries = formatEntries(carbEntries, absorbtionDuration: carbsDuration)
        return InsulinCarbEntry(title: "home_active_carbohydrates".localized,
                                entries: baseChartEntries,
                                unit: Root.EntryType.carbs.shortLabel,
                                color: .carbsChartEntry)
    }
    
    func formatEntries(_ entries: [AbstractEntryProtocol], absorbtionDuration: TimeInterval) -> [BaseChartEntry] {
        var baseChartEntries: [BaseChartEntry] = []
        for index in 0..<entries.count {
            let entry = entries[index]
            guard let entryDate = entry.date else { continue }
            var entryAmount = entry.amount
            guard entryAmount > 0 else { continue }
            let entryEndDate = entryDate.addingTimeInterval(absorbtionDuration)
            var finalEntryAmount = 0.0
            var finalEntryDate = entryEndDate
            
            if index < entries.count - 1 {
                let nextEntry = entries[index + 1]
                guard let nextEntryDate = nextEntry.date else { continue }
                if nextEntryDate < entryEndDate && nextEntry.amount > 0 {
                    let pointX = nextEntryDate.timeIntervalSince1970
                    let startX = entryDate.timeIntervalSince1970
                    let endX = entryEndDate.timeIntervalSince1970
                    finalEntryAmount = ((pointX - startX) * (0.0 - entry.amount)) / (endX - startX) + entry.amount
                    finalEntryDate = nextEntryDate
                }
            }
            
            if index > 0 {
                let prevEntry = entries[index - 1]
                guard let prevEntryDate = prevEntry.date else { continue }
                let endX = prevEntryDate.addingTimeInterval(absorbtionDuration).timeIntervalSince1970
                if entryDate.timeIntervalSince1970 < endX {
                    let pointX = entryDate.timeIntervalSince1970
                    let startX = prevEntryDate.timeIntervalSince1970
                    let lastAmount = ((pointX - startX) * (0.0 - prevEntry.amount)) / (endX - startX) + prevEntry.amount
                    entryAmount += lastAmount
                }
            }
            
            baseChartEntries.append(BaseChartEntry(value: 0.0, date: entryDate))
            baseChartEntries.append(BaseChartEntry(value: entryAmount, date: entryDate))
            baseChartEntries.append(BaseChartEntry(value: finalEntryAmount, date: finalEntryDate))
        }
        return baseChartEntries
    }
    
    func setTimeInterval(_ localInterval: TimeInterval) {
        timeInterval = localInterval
    }
    
    func getChartButtonTitle(_ entryType: Root.EntryType) -> String {
        var entries: [AbstractEntryProtocol]
        var shortLabel: String
        var absorbtionDuration: TimeInterval
        switch entryType {
        case .bolus:
            entries = insulinEntries
            absorbtionDuration = User.current.settings.insulinActionTime
            shortLabel = Root.EntryType.bolus.shortLabel + " >"
        case .carbs:
            entries = carbEntries
            absorbtionDuration = User.current.settings.carbsAbsorptionRate
            shortLabel = Root.EntryType.carbs.shortLabel + " >"
        default:
            return ""
        }
        
        let startDate = Date().timeIntervalSince1970 - timeInterval
        var totalAmount = 0.0
        for index in (0..<entries.count).reversed() {
            let entry = entries[index]
            guard let entryDate = entry.date else { continue }
            let entryAmount = entry.amount
            guard entryAmount > 0 else { continue }
            let entryEndDate = entryDate.addingTimeInterval(absorbtionDuration)
            
            if entryDate.timeIntervalSince1970 >= startDate {
                totalAmount += entryAmount
            } else {
                if entryEndDate.timeIntervalSince1970 > startDate {
                    let pointX = startDate
                    let startX = entryDate.timeIntervalSince1970
                    let endX = entryEndDate.timeIntervalSince1970
                    totalAmount += ((pointX - startX) * (0 - entry.amount)) / (endX - startX) + entry.amount
                    break
                }
            }
        }
        
        return String(format: "%.2f", totalAmount.rounded(to: 2)) + " \(shortLabel)"
    }
}

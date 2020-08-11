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
    func getChartShouldBeShown() -> Bool
    func setTimeInterval(_ localInterval: TimeInterval)
}

final class HomeEntriesFormattingWorker: HomeEntriesFormattingWorkerProtocol {
    private var timeInterval: TimeInterval = .secondsPerHour
    private var insulinEntries: [InsulinEntry] = []
    private var carbEntries: [CarbEntry] = []
    private var currentAmount = 0.0
    
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
        let chartStartInterval = Date().timeIntervalSince1970 - .secondsPerDay
        for index in 0..<entries.count {
            let entry = entries[index]
            guard let entryInterval = entry.date?.timeIntervalSince1970 else { continue }
            var entryAmount = entry.amount
            guard entryAmount > 0 else { continue }
            let entryEndInterval = entryInterval + absorbtionDuration
            guard entryEndInterval >= chartStartInterval else { continue }
            var finalEntryAmount = 0.0
            var finalEntryInterval = entryEndInterval
            
            if index < entries.count - 1 {
                let nextEntry = entries[index + 1]
                guard let nextEntryInterval = nextEntry.date?.timeIntervalSince1970 else { continue }
                if nextEntryInterval < entryEndInterval && nextEntry.amount > 0 {
                    let pointX = nextEntryInterval
                    let startX = entryInterval
                    let startY = entry.amount
                    let endX = entryEndInterval
                    finalEntryAmount = calculatePointYFor(pointX: pointX, startX: startX, startY: startY, endX: endX)
                    finalEntryInterval = nextEntryInterval
                }
            }
            
            if index > 0 {
                let prevEntry = entries[index - 1]
                guard let prevEntryInterval = prevEntry.date?.timeIntervalSince1970 else { continue }
                let endX = prevEntryInterval + absorbtionDuration
                if entryInterval < endX {
                    let pointX = entryInterval
                    let startX = prevEntryInterval
                    let startY = prevEntry.amount
                    let lastAmount = calculatePointYFor(pointX: pointX, startX: startX, startY: startY, endX: endX)
                    entryAmount += lastAmount
                }
            }
            
            baseChartEntries.append(BaseChartEntry(value: 0.0,
                                                   date: Date(timeIntervalSince1970: entryInterval)))
            baseChartEntries.append(BaseChartEntry(value: entryAmount,
                                                   date: Date(timeIntervalSince1970: entryInterval)))
            baseChartEntries.append(BaseChartEntry(value: finalEntryAmount,
                                                   date: Date(timeIntervalSince1970: finalEntryInterval)))
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
        
        return makeButtonTitle(entries: entries, shortLabel: shortLabel, absorbtionDuration: absorbtionDuration)
    }
    
    private func makeButtonTitle(entries: [AbstractEntryProtocol],
                                 shortLabel: String,
                                 absorbtionDuration: TimeInterval) -> String {
        let startInterval = Date().timeIntervalSince1970 - timeInterval
        var totalAmount = 0.0
        for index in (0..<entries.count).reversed() {
            let entry = entries[index]
            guard let entryInterval = entry.date?.timeIntervalSince1970 else { continue }
            var entryAmount = entry.amount
            guard entryAmount > 0 else { continue }
            let entryEndInterval = entryInterval + absorbtionDuration
            
            if entryInterval >= startInterval {
                totalAmount += entryAmount
            } else {
                if entryEndInterval > startInterval {
                    if index > 0 {
                        let prevEntry = entries[index - 1]
                        guard let prevEntryInterval = prevEntry.date?.timeIntervalSince1970 else { continue }
                        let endX = prevEntryInterval + absorbtionDuration
                        if entryInterval < endX {
                            let pointX = entryInterval
                            let startX = prevEntryInterval
                            let startY = prevEntry.amount
                            let lastAmount = calculatePointYFor(pointX: pointX,
                                                                startX: startX,
                                                                startY: startY,
                                                                endX: endX)
                            entryAmount += lastAmount
                        }
                    }
                
                    let pointX = startInterval
                    let startX = entryInterval
                    let endX = entryEndInterval
                    let startY = entryAmount
                    totalAmount += calculatePointYFor(pointX: pointX, startX: startX, startY: startY, endX: endX)
                    break
                }
            }
        }
        
        currentAmount = totalAmount
        
        return String(format: "%.2f", totalAmount.rounded(to: 2)) + " \(shortLabel)"
    }
    
    func getChartShouldBeShown() -> Bool {
        return currentAmount > 0.0
    }
    
    private func calculatePointYFor(pointX: TimeInterval,
                                    startX: TimeInterval,
                                    startY: Double,
                                    endX: TimeInterval) -> Double {
        return ((pointX - startX) * (0.0 - startY)) / (endX - startX) + startY
    }
}

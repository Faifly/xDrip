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
        let baseChartEntries = formatEntries(insulinEntries)
        return InsulinCarbEntry(title: "home_active_insulin".localized,
                                entries: baseChartEntries,
                                unit: Root.EntryType.bolus.shortLabel,
                                color: .bolusChartEntry)
    }
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> InsulinCarbEntry {
        carbEntries = response.carbsData
        let baseChartEntries = formatEntries(carbEntries)
        return InsulinCarbEntry(title: "home_active_carbohydrates".localized,
                                entries: baseChartEntries,
                                unit: Root.EntryType.carbs.shortLabel,
                                color: .carbsChartEntry)
    }
    
    func formatEntries(_ entries: [AbstractEntryProtocol]) -> [BaseChartEntry] {
        var baseChartEntries: [BaseChartEntry] = []
        let chartStartDate = Date().timeIntervalSince1970 - .secondsPerDay
        var amountsArray: [Double] = entries.map { $0.amount }
    
        for index in 0..<entries.count {
            let entry = entries[index]
    
            guard let entryStartDate = entry.date?.timeIntervalSince1970 else { continue }
            guard let entryAbsorptionDuration = entry.absorptionDuration else { continue }
            var entryEndDate = entryStartDate + entryAbsorptionDuration
            var entryEndAmount = 0.0
          
            guard amountsArray[index] > 0 else { continue }
            guard entryEndDate >= chartStartDate else { continue }
         
            if index > 0 {
                let prevEntry = entries[index - 1]
                guard let prevEntryDate = prevEntry.date?.timeIntervalSince1970 else { continue }
                guard let prevEntryAbsorptionDuration = prevEntry.absorptionDuration else { continue }
                let prevEntryEndDate = prevEntryDate + prevEntryAbsorptionDuration
                if entryStartDate < prevEntryEndDate {
                    let pointX = entryStartDate
                    let startX = prevEntryDate
                    let startY = amountsArray[index - 1]
                    let endX = prevEntryEndDate
                    let lastAmount = calculatePointYFor(pointX: pointX, startX: startX, startY: startY, endX: endX)
                    amountsArray[index] += lastAmount
                }
            }
            
            if index < entries.count - 1 {
                let nextEntry = entries[index + 1]
                guard let nextEntryStartDate = nextEntry.date?.timeIntervalSince1970 else { continue }
                if nextEntryStartDate < entryEndDate && amountsArray[index + 1] > 0 {
                    let pointX = nextEntryStartDate
                    let startX = entryStartDate
                    let startY = amountsArray[index]
                    let endX = entryEndDate
                    entryEndAmount = calculatePointYFor(pointX: pointX, startX: startX, startY: startY, endX: endX)
                    entryEndDate = nextEntryStartDate
                }
            }
            
            baseChartEntries.append(BaseChartEntry(value: 0.0,
                                                   date: Date(timeIntervalSince1970: entryStartDate)))
            baseChartEntries.append(BaseChartEntry(value: amountsArray[index],
                                                   date: Date(timeIntervalSince1970: entryStartDate)))
            baseChartEntries.append(BaseChartEntry(value: entryEndAmount,
                                                   date: Date(timeIntervalSince1970: entryEndDate)))
        }
        return baseChartEntries
    }
    
    func setTimeInterval(_ localInterval: TimeInterval) {
        timeInterval = localInterval
    }
    
    func getChartButtonTitle(_ entryType: Root.EntryType) -> String {
        var entries: [AbstractEntryProtocol]
        var shortLabel: String
        switch entryType {
        case .bolus:
            entries = insulinEntries
            shortLabel = Root.EntryType.bolus.shortLabel + " >"
        case .carbs:
            entries = carbEntries
            shortLabel = Root.EntryType.carbs.shortLabel + " >"
        default:
            return ""
        }
        
        return makeButtonTitle(entries: entries, shortLabel: shortLabel)
    }
    
    private func makeButtonTitle(entries: [AbstractEntryProtocol],
                                 shortLabel: String) -> String {
        let startInterval = Date().timeIntervalSince1970 - timeInterval
        var totalAmount = 0.0
        for index in (0..<entries.count).reversed() {
            let entry = entries[index]
            guard let entryInterval = entry.date?.timeIntervalSince1970 else { continue }
            guard let entryAbsorptionDuration = entry.absorptionDuration else { continue }
            var entryAmount = entry.amount
            guard entryAmount > 0 else { continue }
            let entryEndInterval = entryInterval + entryAbsorptionDuration
            
            if entryInterval >= startInterval {
                totalAmount += entryAmount
            } else {
                if entryEndInterval > startInterval {
                    if index > 0 {
                        let prevEntry = entries[index - 1]
                        guard let prevEntryInterval = prevEntry.date?.timeIntervalSince1970 else { continue }
                        guard let prevEntryAbsorptionDuration = prevEntry.absorptionDuration else { continue }
                        let endX = prevEntryInterval + prevEntryAbsorptionDuration
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

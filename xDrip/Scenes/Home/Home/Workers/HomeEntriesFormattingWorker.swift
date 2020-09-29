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

private class ChartEntry {
    var amount: Double
    let startDate: Date
    var endDate: Date
    
    init(amount: Double, startDate: Date, endDate: Date) {
        self.amount = amount
        self.startDate = startDate
        self.endDate = endDate
    }
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
    
    func formatEntries(_ entries: [AbstractAbsorbableEntryProtocol]) -> [BaseChartEntry] {
        let entries = createChartEntriesFrom(entries)
        var baseChartEntries: [BaseChartEntry] = []
        let chartStartDate = Date().addingTimeInterval(-.secondsPerDay)
        
        for entry in entries {
            adjustEntryAmount(entries, entry)
            
            guard entry.endDate > chartStartDate else { continue }
            
            baseChartEntries.append(BaseChartEntry(value: 0.0,
                                                   date: entry.startDate))
            baseChartEntries.append(BaseChartEntry(value: entry.amount,
                                                   date: entry.startDate))
            baseChartEntries.append(BaseChartEntry(value: 0.0,
                                                   date: entry.endDate))
        }
        return baseChartEntries
    }
    
    func setTimeInterval(_ localInterval: TimeInterval) {
        timeInterval = localInterval
    }
    
    func getChartButtonTitle(_ entryType: Root.EntryType) -> String {
        var entries: [AbstractAbsorbableEntryProtocol]
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
    
    private func createChartEntriesFrom(_ entries: [AbstractAbsorbableEntryProtocol]) -> [ChartEntry] {
        var objects: [ChartEntry] = []
        for entry in entries {
            guard entry.amount > 0.0 else { continue }
            guard let date = entry.date else { continue }
            guard entry.absorptionDuration > 0.0 else { continue }
            
            objects.append(ChartEntry(amount: entry.amount,
                                      startDate: date,
                                      endDate: date + entry.absorptionDuration))
        }
        return objects
    }
    
    private func makeButtonTitle(entries: [AbstractAbsorbableEntryProtocol],
                                 shortLabel: String) -> String {
        let startDate = Date().addingTimeInterval(-timeInterval)
        let entries = createChartEntriesFrom(entries)
        var totalAmount = 0.0
        
        let includedEntries = entries.filter({ $0.startDate >= startDate })
        includedEntries.forEach { entry in totalAmount += entry.amount }
        
        entries.forEach { entry in adjustEntryAmount(entries, entry) }
        
        let partiallyIncluded = entries.filter({ $0.startDate < startDate && $0.endDate > startDate })
        if let closestEntry = partiallyIncluded.max(by: { $0.startDate < $1.startDate }) {
            totalAmount += calculatePointYFor(pointX: startDate,
                                              startX: closestEntry.startDate,
                                              startY: closestEntry.amount,
                                              endX: closestEntry.endDate)
        }
        
        currentAmount = totalAmount
        
        return String(format: "%.2f", totalAmount.rounded(to: 2)) + " \(shortLabel)"
    }
    
    private func adjustEntryAmount(_ objects: [ChartEntry], _ entry: ChartEntry) {
        let crossedEntries = objects.filter({ $0.startDate < entry.startDate && $0.endDate > entry.startDate })
        if let closestEntry = crossedEntries.max(by: { $0.startDate < $1.startDate }) {
            entry.amount += calculatePointYFor(pointX: entry.startDate,
                                               startX: closestEntry.startDate,
                                               startY: closestEntry.amount,
                                               endX: closestEntry.endDate)
        }
    }
    
    func getChartShouldBeShown() -> Bool {
        return currentAmount > 0.0
    }
    
    private func calculatePointYFor(pointX: Date,
                                    startX: Date,
                                    startY: Double,
                                    endX: Date) -> Double {
        let pointX = pointX.timeIntervalSince1970
        let startX = startX.timeIntervalSince1970
        let endX = endX.timeIntervalSince1970
        
        return ((pointX - startX) * (0.0 - startY)) / (endX - startX) + startY
    }
}

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
    
    func formatEntries(_ entries: [AbstractEntryProtocol]) -> [BaseChartEntry] {
        let objects = createChartEntriesFrom(entries)
        var baseChartEntries: [BaseChartEntry] = []
        let chartStartDate = Date().addingTimeInterval(-.secondsPerDay)
        
        for index in 0..<objects.count {
            let entry = objects[index]
            
            if index > 0 {
                let prevEntry = objects[index - 1]
                if entry.startDate < prevEntry.endDate {
                    let lastAmount = calculatePointYFor(pointX: entry.startDate,
                                                        startX: prevEntry.startDate,
                                                        startY: prevEntry.amount,
                                                        endX: prevEntry.endDate)
                    entry.amount += lastAmount
                }
            }
            
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
    
    private func createChartEntriesFrom(_ entries: [AbstractEntryProtocol]) -> [ChartEntry] {
        var objects: [ChartEntry] = []
        for entry in entries {
            guard entry.amount > 0.0 else { continue }
            guard let date = entry.date else { continue }
            guard let asorptionDuration = entry.absorptionDuration else { continue }
            
            objects.append(ChartEntry(amount: entry.amount,
                                      startDate: date,
                                      endDate: date + asorptionDuration))
        }
        return objects
    }
    
    private func makeButtonTitle(entries: [AbstractEntryProtocol],
                                 shortLabel: String) -> String {
        let startDate = Date().addingTimeInterval(-timeInterval)
        let objects = createChartEntriesFrom(entries)
        var totalAmount = 0.0
        var partiallyIncluded: [ChartEntry] = []
        
        for index in 0..<objects.count {
            let entry = objects[index]
            
            if entry.startDate >= startDate {
                totalAmount += entry.amount
            }
            
            if index > 0 {
                let prevEntry = objects[index - 1]
                if entry.startDate < prevEntry.endDate {
                    let lastAmount = calculatePointYFor(pointX: entry.startDate,
                                                        startX: prevEntry.startDate,
                                                        startY: prevEntry.amount,
                                                        endX: prevEntry.endDate)
                    entry.amount += lastAmount
                }
            }
            
            if entry.startDate < startDate && entry.endDate > startDate {
                partiallyIncluded.append(entry)
            }
        }
        
        if let closestEntry = partiallyIncluded.max(by: { $0.startDate < $1.startDate }) {
            totalAmount += calculatePointYFor(pointX: startDate,
                                              startX: closestEntry.startDate,
                                              startY: closestEntry.amount,
                                              endX: closestEntry.endDate)
        }
        
        currentAmount = totalAmount
        
        return String(format: "%.2f", totalAmount.rounded(to: 2)) + " \(shortLabel)"
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

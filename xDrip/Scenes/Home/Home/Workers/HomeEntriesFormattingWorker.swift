//
//  HomeEntriesFormattingWorker.swift
//  xDrip
//
//  Created by Dmitry on 6/26/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import AKUtils

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
    func getChartShouldBeShown(_ entryType: Root.EntryType) -> Bool
    func setTimeInterval(_ localInterval: TimeInterval)
    func calculateChartValues(for hours: Int, allBasals: [InsulinEntry]) -> [BaseChartEntry]
    func calculateChartValues(for date: Date, allBasals: [InsulinEntry]) -> [BaseChartEntry]
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
        let currentDate = Date()
        let entries = createChartEntriesFrom(entries).sorted(by: { $0.startDate < $1.startDate })
        entries.forEach { entry in adjustEntryAmount(entries, entry) }
        
        let validEntries = entries.filter({ $0.endDate > currentDate })
        var totalAmount = 0.0
        
        for entry in validEntries {
            let pointY = calculatePointYFor(pointX: currentDate,
                                            startX: entry.startDate,
                                            startY: entry.amount,
                                            endX: entry.endDate)
            
            if totalAmount < pointY {
                totalAmount = pointY
            }
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
    
    func getChartShouldBeShown(_ entryType: Root.EntryType) -> Bool {
        switch entryType {
        case .bolus:
            return !insulinEntries.isEmpty
        case .carbs:
            return !carbEntries.isEmpty
        default:
            return true
        }
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
    
    private func getBasalValueForDate(date: Date, allBasals: [InsulinEntry]) -> Double {
        let minimumDate = date - .secondsPerDay * 3.0
        let all = allBasals.filter({ $0.date >=? minimumDate &&
            $0.date <=? date && $0.isValid })
        let entries = all.map({ BaseChartEntry(value: $0.amount, date: $0.date ?? Date()) })
        
        guard date >= minimumDate else { return 0.0 }
        guard !entries.isEmpty else { return 0.0 }
        
        var lastValue = entries[0].value
        var prevEntry: BaseChartEntry?
        for (index, entry) in entries.enumerated() {
            if index != 0 {
                calculateValue(prevEntry: prevEntry, toDate: entry.date, lastValue: &lastValue)
                lastValue += entry.value
            }
            prevEntry = entry
        }
        calculateValue(prevEntry: prevEntry, toDate: date, lastValue: &lastValue)
        
        return lastValue
    }
    
    @discardableResult
    private func calculateValue(prevEntry: BaseChartEntry?,
                                toDate: Date?,
                                lastValue: inout Double) -> [BaseChartEntry] {
        guard let prevEntry = prevEntry else { return [] }
        let prevDate = prevEntry.date
        let basalRates = User.current.settings.sortedBasalRates
        guard !basalRates.isEmpty else { return [] }
        
        var intermediateValues = [BaseChartEntry]()
        
        var lastDate = prevDate
        let startOfDay = Calendar.current.startOfDay(for: prevDate)
        let prevEntryStartTime = prevDate.timeIntervalSince(startOfDay)
        let currentEntryStartTime = (toDate ?? Date()).timeIntervalSince(startOfDay)
        
        var rates = calculateRates(for: prevEntryStartTime, and: currentEntryStartTime)
        let unitsPerHour = Double(rates[0].units)
        rates.removeFirst()
        
        func calcValue(startTime: TimeInterval) {
            let time = startOfDay.addingTimeInterval(startTime)
            let interval = time.timeIntervalSince(lastDate)
            let diff = unitsPerHour * interval.hours
            
            if lastValue - diff >= 0.0 {
                lastValue -= diff
                intermediateValues.append(BaseChartEntry(value: lastValue, date: time))
            } else {
                let interval = TimeInterval.hours(lastValue / unitsPerHour)
                let date = lastDate.addingTimeInterval(interval)
                lastValue = 0.0
                
                intermediateValues.append(BaseChartEntry(value: 0.0, date: date))
                intermediateValues.append(BaseChartEntry(value: 0.0, date: time))
            }
            
            lastDate = time
        }
        
        for index in 0 ..< rates.endIndex {
            calcValue(startTime: rates[index].startTime)
        }
        calcValue(startTime: currentEntryStartTime)
        
        return intermediateValues
    }
    
    private func calculateRates(for startTime: TimeInterval, and endTime: TimeInterval) -> [BasalRate] {
        let basalRates = User.current.settings.sortedBasalRates
        var rates = basalRates
        for basalRate in basalRates {
            rates.append(contentsOf:
                            [
                                BasalRate(startTime: basalRate.startTime - .secondsPerDay * 3.0, units: basalRate.units),
                                BasalRate(startTime: basalRate.startTime - .secondsPerDay * 2.0, units: basalRate.units),
                                BasalRate(startTime: basalRate.startTime - .secondsPerDay, units: basalRate.units),
                                BasalRate(startTime: basalRate.startTime + .secondsPerDay, units: basalRate.units),
                                BasalRate(startTime: basalRate.startTime + .secondsPerDay * 2.0, units: basalRate.units),
                                BasalRate(startTime: basalRate.startTime + .secondsPerDay * 3.0, units: basalRate.units)
                            ]
            )
        }
        rates.sort(by: { $0.startTime < $1.startTime })
        
        var minIndex = 0
        var maxIndex = rates.endIndex - 1
        for index in 0 ..< rates.endIndex - 1 {
            if rates[index].startTime <= startTime && rates[index + 1].startTime > startTime {
                minIndex = index
            }
            if rates[index].startTime <= endTime, rates[index + 1].startTime > endTime {
                maxIndex = index
            }
        }
        
        return Array(rates[minIndex ... maxIndex])
    }
    
    func calculateChartValues(for hours: Int, allBasals: [InsulinEntry]) -> [BaseChartEntry] {
        let minimumDate = Date() - TimeInterval(hours) * .secondsPerHour
        let all = allBasals.filter({ $0.date >=? minimumDate &&
            $0.isValid })
        
        if (User.current.settings.deviceMode == .follower) {
            return formatEntries(all)
        } else {
            let entries = all.map({ BaseChartEntry(value: $0.amount, date: $0.date ?? Date()) })
            
            var points = [BaseChartEntry]()
            
            var lastValue = getBasalValueForDate(date: minimumDate, allBasals: allBasals)
            var prevEntry = BaseChartEntry(value: lastValue, date: minimumDate)
            points.append(prevEntry)
            for entry in entries {
                points.append(contentsOf: calculateValue(prevEntry: prevEntry, toDate: entry.date, lastValue: &lastValue))
                lastValue += entry.value
                points.append(BaseChartEntry(value: lastValue, date: entry.date))
                prevEntry = entry
            }
            points.append(contentsOf:
                            calculateValue(prevEntry: prevEntry, toDate: Date() + .secondsPerHour * 6.0, lastValue: &lastValue)
            )
            points.sort { first, second -> Bool in
                if first.date == second.date {
                    return first.value < second.value
                }
                return first.date <? second.date
            }
            
            return points
        }
    }
    
    func calculateChartValues(for date: Date, allBasals: [InsulinEntry]) -> [BaseChartEntry] {
        let minimumDate = Calendar.current.startOfDay(for: date)
        let maximumDate = minimumDate + .secondsPerDay
        let all = allBasals.filter({
            $0.date >=? minimumDate && $0.date <=? maximumDate && $0.isValid
        })
        
        if (User.current.settings.deviceMode == .follower) {
            return formatEntries(all)
        } else {
            let entries = all.map({ BaseChartEntry(value: $0.amount, date: $0.date ?? Date()) })
            
            var points = [BaseChartEntry]()
            
            var lastValue = getBasalValueForDate(date: minimumDate, allBasals: allBasals)
            var prevEntry = BaseChartEntry(value: lastValue, date: minimumDate)
            points.append(prevEntry)
            for entry in entries {
                points.append(contentsOf: calculateValue(prevEntry: prevEntry, toDate: entry.date, lastValue: &lastValue))
                lastValue += entry.value
                points.append(BaseChartEntry(value: lastValue, date: entry.date))
                prevEntry = entry
            }
            points.append(contentsOf:
                            calculateValue(prevEntry: prevEntry, toDate: maximumDate, lastValue: &lastValue)
            )
            points.sort { first, second -> Bool in
                if first.date == second.date {
                    return first.value < second.value
                }
                return first.date <? second.date
            }
            
            return points
        }
        
        
    }
}

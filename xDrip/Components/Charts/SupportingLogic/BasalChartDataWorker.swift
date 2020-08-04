//
//  BasalChartDataWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 22.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AKUtils

enum BasalChartDataWorker {
    static func fetchBasalData() -> [InsulinEntry] {
        let minimumDate = Date() - .secondsPerDay
        let all = InsulinEntriesWorker.fetchAllBasalEntries()
        return all.filter { $0.date >=? minimumDate }
    }
    
    static func getBasalValueForDate(date: Date) -> Double {
        let minimumDate = Date() - .secondsPerDay * 3.0
        guard date >= minimumDate else { return 0.0 }
        let all = InsulinEntriesWorker.fetchAllBasalEntries().filter({ $0.date >=? minimumDate })
        
        guard !all.isEmpty else { return 0.0 }
        
        var lastValue = all[0].amount
        var prevEntry: InsulinEntry?
        for (index, entry) in all.enumerated() {
            if entry.date >? date { break }
            if index != 0 {
                calculateValue(prevEntry: prevEntry, toDate: entry.date, lastValue: &lastValue)
                lastValue += entry.amount
            }
            prevEntry = entry
        }
        calculateValue(prevEntry: prevEntry, toDate: date, lastValue: &lastValue)
        
        return lastValue
    }
    
    @discardableResult
    private static func calculateValue(
        prevEntry: InsulinEntry?,
        toDate: Date?,
        lastValue: inout Double
    ) -> [InsulinEntry] {
        guard let prevEntry = prevEntry, let prevDate = prevEntry.date else { return [] }
        let basalRates = User.current.settings.sortedBasalRates
        guard !basalRates.isEmpty else { return [] }
        
        var intermediateValues = [InsulinEntry]()
        
        var lastDate = prevDate
        let startOfDay = Calendar.current.startOfDay(for: prevDate)
        let prevEntryStartTime = prevDate.timeIntervalSince(startOfDay)
        let currentEntryStartTime = (toDate ?? Date()).timeIntervalSince(startOfDay)
        
        var rates = calculateRates(for: prevEntryStartTime, and: currentEntryStartTime)
        var unitsPerHour = Double(rates[0].units)
        rates.removeFirst()
        
        func calcValue(startTime: TimeInterval) {
            let time = startOfDay.addingTimeInterval(startTime)
            let interval = time.timeIntervalSince(lastDate)
            let diff = unitsPerHour * interval.hours
            
            if lastValue - diff >= 0.0 {
                lastValue -= diff
                intermediateValues.append(InsulinEntry(amount: lastValue, date: time, type: .basal))
            } else {
                let interval = TimeInterval.hours(lastValue / unitsPerHour)
                let date = lastDate.addingTimeInterval(interval)
                lastValue = 0.0
                
                intermediateValues.append(InsulinEntry(amount: 0.0, date: date, type: .basal))
                intermediateValues.append(InsulinEntry(amount: 0.0, date: time, type: .basal))
            }
            
            lastDate = time
        }
        
        for index in 0 ..< rates.endIndex {
            calcValue(startTime: rates[index].startTime)
        }
        calcValue(startTime: currentEntryStartTime)
        
        return intermediateValues
    }
    
    private static func calculateRates(for startTime: TimeInterval, and endTime: TimeInterval) -> [BasalRate] {
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
    
    static func calculateChartValues() -> [InsulinEntry] {
        let minimumDate = Date() - .secondsPerDay
        let all = InsulinEntriesWorker.fetchAllBasalEntries().filter({ $0.date >=? minimumDate })
        
        var points = [InsulinEntry]()
        
        var lastValue = getBasalValueForDate(date: minimumDate)
        var prevEntry = InsulinEntry(amount: lastValue, date: minimumDate, type: .basal)
        points.append(prevEntry)
        for entry in all {
            points.append(contentsOf: calculateValue(prevEntry: prevEntry, toDate: entry.date, lastValue: &lastValue))
            lastValue += entry.amount
            points.append(InsulinEntry(amount: lastValue, date: entry.date ?? Date(), type: .basal))
            prevEntry = entry
        }
        points.append(contentsOf:
            calculateValue(prevEntry: prevEntry, toDate: Date() + .secondsPerHour * 6.0, lastValue: &lastValue)
        )
        points.sort { first, second -> Bool in
            if first.date == second.date {
                return first.amount < second.amount
            }
            return first.date <? second.date
        }
        
        return points
    }
}

//
//  BasalChartProvider.swift
//  xDrip
//
//  Created by Ivan Skoryk on 21.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol BasalChartProvider: GlucoseChartProvider {
    var yRangeBasal: ClosedRange<Double> { get }
    var basalEntries: [BasalChartEntry] { get }
    var basalDisplayMode: ChartSettings.BasalDisplayMode { get }
    var pixelPerValueBasal: Double { get set }
    var yIntervalBasal: Double { get set }
    var basalRates: [BasalRate] { get set }
    
    func drawBasalStroke()
}

private struct BasalEntry: BasalChartEntry {
    var value: Double
    var date: Date
}

extension BasalChartProvider where Self: GlucoseChartProvider & UIView {
    private var yMin: Double {
        return basalDisplayMode == .onBottom ? yInterval : 0
    }
    
    private var yMax: Double {
        return basalDisplayMode == .onBottom ? yInterval - yIntervalBasal : yIntervalBasal
    }
    
    private var extendedRates: [BasalRate] {
        var rates = basalRates
        let dayInterval = TimeInterval.hours(24.0)
        for basalRate in basalRates {
            let prevRate = BasalRate(startTime: basalRate.startTime - dayInterval, units: basalRate.units)
            let nextRate = BasalRate(startTime: basalRate.startTime + dayInterval, units: basalRate.units)
            rates.append(contentsOf: [prevRate, nextRate])
        }
        rates.sort(by: { $0.startTime < $1.startTime })
        
        return rates
    }
    
    func drawBasalStroke() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard basalDisplayMode != .notShown else { return }
        guard !basalEntries.isEmpty else { return }
        calculateValues()
        
        var lastValue = InsulinEntriesWorker.getBasalValueForDate(date: dateInterval
            .start)// basalEntries[0].value
        var prevEntry: BasalChartEntry = BasalEntry(value: lastValue, date: dateInterval.start)
        context.move(to: calcPoint(for: dateInterval.start, and: lastValue))
        
        for entry in basalEntries {
            setReducedBasalValue(prevEntry: prevEntry, toDate: entry.date, lastValue: &lastValue)

            lastValue += entry.value
            
            let tmpPath = context.path
            
            let point = calcPoint(for: entry.date, and: lastValue)
            let circleRect = CGRect(
                x: point.x - circleSide / 2.0,
                y: point.y - circleSide / 2.0,
                width: circleSide,
                height: circleSide
            )
            
            context.setFillColor(UIColor.cyan.cgColor)
            context.fillEllipse(in: circleRect)
            
            if let path = tmpPath {
                context.addPath(path)
            }
            
            context.addLine(to: point)
            
            prevEntry = entry
        }
        setReducedBasalValue(prevEntry: prevEntry, toDate: nil, lastValue: &lastValue)
        
        context.addLine(to: CGPoint(x: bounds.width - insets.left - insets.right, y: CGFloat(yMin) + insets.top))
        
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.cyan.cgColor)
        
        let path = context.path
        context.drawPath(using: .stroke)
        completeBasalChart(for: path)
    }
    
    private func completeBasalChart(for path: CGPath?) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let path = path else { return }
        context.addPath(path)
        
        let strokeInset: CGFloat = basalDisplayMode == .onBottom ? 2.0 : -2.0
        context.addLine(to: CGPoint(
                x: bounds.width - insets.left - insets.right,
                y: CGFloat(yMin) + insets.top + strokeInset
            )
        )
        context.addLine(to: CGPoint(x: 0.0, y: CGFloat(yMin) + insets.top + strokeInset))
        
        context.setFillColor(UIColor.cyan.withAlphaComponent(0.2).cgColor)
        context.drawPath(using: .fill)
    }
    
    private func setReducedBasalValue(prevEntry: BasalChartEntry, toDate: Date?, lastValue: inout Double) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if basalRates.count == 1 {
            let unitsPerHour = Double(basalRates[0].units)
            
            let date = toDate ?? Date()
            let diff = unitsPerHour * date.timeIntervalSince(prevEntry.date).hours
            
            if lastValue - diff >= 0.0 {
                context.addLine(to: calcPoint(for: date, and: lastValue - diff))
                
                lastValue -= diff
            } else {
                let date = prevEntry.date.addingTimeInterval(.hours(prevEntry.value / unitsPerHour))
                context.addLine(to: calcPoint(for: date, and: 0.0))
                
                if let toDate = toDate {
                    context.addLine(to: calcPoint(for: toDate, and: 0.0))
                }
                
                lastValue = 0.0
            }
        } else {
            var lastDate = prevEntry.date
            
            let startOfDay = Calendar.current.startOfDay(for: prevEntry.date)
            let prevEntryStartTime = prevEntry.date.timeIntervalSince(startOfDay)
            let currentEntryStartTime = (toDate ?? Date()).timeIntervalSince(startOfDay)
            
            var rates = calculateRates(for: prevEntryStartTime, and: currentEntryStartTime)
            var unitsPerHour = Double(rates[0].units)
            rates.removeFirst()
            for index in 0 ..< rates.endIndex {
                addLine(
                    for: rates[index].startTime,
                    lastDate: &lastDate,
                    lastValue: &lastValue,
                    startOfDay: startOfDay,
                    unitsPerHour: unitsPerHour
                )
                unitsPerHour = Double(rates[index].units)
            }
            addLine(
                for: currentEntryStartTime,
                lastDate: &lastDate,
                lastValue: &lastValue,
                startOfDay: startOfDay,
                unitsPerHour: unitsPerHour
            )
        }
        
        if toDate == nil {
            context.addLine(to: calcPoint(for: Date(), and: 0.0))
        }
    }
    
    private func addLine(
        for startTime: TimeInterval,
        lastDate: inout Date,
        lastValue: inout Double,
        startOfDay: Date,
        unitsPerHour: Double
    ) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let time = startOfDay.addingTimeInterval(startTime)
        let interval = time.timeIntervalSince(lastDate)
        let diff = unitsPerHour * interval.hours
        
        if lastValue - diff >= 0.0 {
            context.addLine(to: calcPoint(for: time, and: lastValue - diff))
            
            lastValue -= diff
        } else {
            let interval = TimeInterval.hours(lastValue / unitsPerHour)
            let date = lastDate.addingTimeInterval(interval)
            
            context.addLine(to: calcPoint(for: date, and: 0.0))
            context.addLine(to: calcPoint(for: time, and: 0.0))
            
            lastValue = 0.0
        }
        
        lastDate = time
    }
    
    private func calcPoint(for date: Date, and value: Double) -> CGPoint {
        guard basalDisplayMode != .notShown else { return .zero }
        
        let value = basalDisplayMode == .onBottom ? value : -value
        let yMax = basalDisplayMode == .onBottom ? self.yMax : -self.yMax
        
        let xPoint = CGFloat((date.timeIntervalSince1970 - minDate) * pixelsPerSecond) + insets.left
        let yPoint = CGFloat((yRangeBasal.upperBound - value) * pixelPerValueBasal) + insets.top + CGFloat(yMax)
        
        return CGPoint(x: xPoint, y: yPoint)
    }
    
    private func calculateRates(for startTime: TimeInterval, and endTime: TimeInterval) -> [BasalRate] {
        let rates = extendedRates
        
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
    
    private func calculateValues() {
        minDate = dateInterval.start.timeIntervalSince1970
        maxDate = dateInterval.end.timeIntervalSince1970
        timeInterval = maxDate - minDate
        pixelsPerSecond = Double(bounds.width - insets.left - insets.right) / timeInterval
        yInterval = Double(bounds.height - insets.bottom - insets.top)
        pixelsPerValue = yInterval / (yRange.upperBound - yRange.lowerBound)
        yIntervalBasal = yInterval / 4.0
        
        guard !basalEntries.isEmpty else { return }
        pixelPerValueBasal = yIntervalBasal / (yRangeBasal.upperBound - yRangeBasal.lowerBound)
    }
}

//
//  GlucoseChartProvider.swift
//  xDrip
//
//  Created by Artem Kalmykov on 16.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import AKUtils

protocol GlucoseChartProvider {
    var dateInterval: DateInterval { get }
    var yRange: ClosedRange<Double> { get }
    var entries: [GlucoseChartGlucoseEntry] { get }
    var basalEntries: [BasalChartEntry] { get }
    var insets: UIEdgeInsets { get }
    var circleSide: CGFloat { get }
    
    func drawGlucoseChart()
}

private struct BasalEntry: BasalChartEntry {
    var value: Double
    var date: Date
}

// swiftlint:disable function_body_length

extension GlucoseChartProvider where Self: UIView {
    private var minDate: TimeInterval {
        return dateInterval.start.timeIntervalSince1970
    }
    
    private var maxDate: TimeInterval {
        return dateInterval.end.timeIntervalSince1970
    }
    
    private var timeInterval: TimeInterval {
        return maxDate - minDate
    }
    
    private var pixelsPerSecond: Double {
        return Double(bounds.width - insets.left - insets.right) / timeInterval
    }
    
    private var yInterval: Double {
        return Double(bounds.height - insets.bottom - insets.top)
    }
    
    private var pixelsPerValue: Double {
        return yInterval / (yRange.upperBound - yRange.lowerBound)
    }
    
    func drawGlucoseChart() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineWidth(0.0)
        
        for entry in entries {
            let centerX = CGFloat((entry.date.timeIntervalSince1970 - minDate) * pixelsPerSecond) + insets.left
            let centerY = CGFloat((yRange.upperBound - entry.value) * pixelsPerValue) + insets.top
            let circleRect = CGRect(
                x: centerX - circleSide / 2.0,
                y: centerY - circleSide / 2.0,
                width: circleSide,
                height: circleSide
            )
    
            let color = UIColor.colorForSeverityLevel(entry.severity)
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: circleRect)
        }
        
        drawBasalStroke()
    }
    
    func drawBasalStroke() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let displayMode = User.current.settings.chart?.basalDisplayMode, displayMode != .notShown else { return }
        let yIntervalBasal = yInterval / 4.0
        let yMax = displayMode == .onBottom ? yInterval - yIntervalBasal : yIntervalBasal
        let yMin = displayMode == .onBottom ? yInterval : 0
        
        guard var max = basalEntries.map({ $0.value }).max() else { return }
        
        let min = 0.0
        max = max.rounded(.up)
        
        if max ~~ min {
            max += 1.0
        }
        
        let pxlPerVal = yIntervalBasal / (max - min)
        
        func calcPoint(for date: Date, and value: Double) -> CGPoint {
            let value = displayMode == .onBottom ? value : -value
            let yMax = displayMode == .onBottom ? yMax : -yMax
            
            let xPoint = CGFloat((date.timeIntervalSince1970 - minDate) * pixelsPerSecond) + insets.left
            let yPoint = CGFloat((max - value) * pxlPerVal) + insets.top + CGFloat(yMax)
            
            return CGPoint(x: xPoint, y: yPoint)
        }
        
        var lastValue = 0.0
        func setReducedBasalValue(prevEntry: BasalChartEntry?, toDate: Date?, in context: CGContext) {
            guard let prevEntry = prevEntry else { return }
            let basalRates = User.current.settings.sortedBasalRates
            var unitsPerHour = 0.0
            
            if basalRates.count == 1 {
                unitsPerHour = Double(basalRates[0].units)
                
                let date = toDate ?? Date()
                let interval = date.timeIntervalSince(prevEntry.date)
                let diff = unitsPerHour * interval.hours
                
                if lastValue - diff >= 0.0 {
                    context.addLine(to: calcPoint(for: date, and: prevEntry.value - diff))
                    
                    if date != toDate {
                        context.addLine(to: calcPoint(for: date, and: 0.0))
                    }
                    lastValue -= diff
                } else {
                    let interval = TimeInterval.hours(prevEntry.value / unitsPerHour)
                    let date = prevEntry.date.addingTimeInterval(interval)
                    context.addLine(to: calcPoint(for: date, and: 0.0))
                    
                    if let toDate = toDate {
                        context.addLine(to: calcPoint(for: toDate, and: 0.0))
                    }
                    
                    lastValue = 0.0
                }
            } else {
                var lastDate = prevEntry.date
                func addLine(for startTime: TimeInterval, context: CGContext) {
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
                
                // fill rates
                var rates = basalRates
                
                let dayInterval = TimeInterval.hours(24.0)
                for basalRate in basalRates {
                    let prevRate = BasalRate(startTime: basalRate.startTime - dayInterval, units: basalRate.units)
                    let nextRate = BasalRate(startTime: basalRate.startTime + dayInterval, units: basalRate.units)
                    rates.append(contentsOf: [prevRate, nextRate])
                }
                rates.sort(by: { $0.startTime < $1.startTime })
                
                let startOfDay = Calendar.current.startOfDay(for: prevEntry.date)
                let prevEntryStartTime = prevEntry.date.timeIntervalSince(startOfDay)
                let currentEntryStartTime = (toDate ?? Date()).timeIntervalSince(startOfDay)
                
                var minIndex = 0
                var maxIndex = rates.endIndex - 1
                for index in 0 ..< rates.endIndex - 1 {
                    if rates[index].startTime <= prevEntryStartTime && rates[index + 1].startTime > prevEntryStartTime {
                        minIndex = index
                    }
                    if rates[index].startTime <= currentEntryStartTime,
                        rates[index + 1].startTime > currentEntryStartTime {
                        maxIndex = index
                    }
                }
                
                rates = Array(rates[minIndex ... maxIndex])
                
                // construct path
                unitsPerHour = Double(rates[0].units)
                rates.removeFirst()
                for index in 0 ..< rates.endIndex {
                    addLine(for: rates[index].startTime, context: context)
                    unitsPerHour = Double(rates[index].units)
                }
                
                addLine(for: currentEntryStartTime, context: context)
                
                if toDate == nil {
                    context.addLine(to: calcPoint(for: Date(), and: 0.0))
                }
            }
        }
        
        lastValue = basalEntries[0].value
        context.move(to: CGPoint(x: 0.0, y: yMin + Double(insets.top)))
        context.addLine(to: calcPoint(for: basalEntries[0].date, and: 0.0))
        context.addLine(to: calcPoint(for: basalEntries[0].date, and: basalEntries[0].value))
        
        var prevEntry: BasalChartEntry?
        for (index, entry) in basalEntries.enumerated() {
            if index != 0 {
                setReducedBasalValue(prevEntry: prevEntry, toDate: entry.date, in: context)

                lastValue += entry.value
            }
            
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
        setReducedBasalValue(prevEntry: prevEntry, toDate: nil, in: context)
        
        context.addLine(to: CGPoint(x: bounds.width - insets.left - insets.right, y: CGFloat(yMin) + insets.top))
        
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.cyan.cgColor)
        
        let optPath = context.path
        context.drawPath(using: .stroke)
        
        guard let path = optPath else {
            return
        }
        
        context.addPath(path)
        
        let strokeInset: CGFloat = displayMode == .onBottom ? 2.0 : -2.0
        context.addLine(to: CGPoint(x: bounds.width - insets.left - insets.right, y: CGFloat(yMin) + insets.top + strokeInset))
        context.addLine(to: CGPoint(x: 0.0, y: CGFloat(yMin) + insets.top + strokeInset))
        
        context.setFillColor(UIColor.cyan.withAlphaComponent(0.2).cgColor)
        context.drawPath(using: .fill)
    }
}

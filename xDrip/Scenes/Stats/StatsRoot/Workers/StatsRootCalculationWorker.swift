//
//  StatsRootCalculationWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 22.07.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

// swiftlint:disable function_body_length

import UIKit

protocol StatsRootCalculationWorkerLogic {
    func calculate(with readings: [BaseGlucoseReading], lowThreshold: Double, highThreshold: Double)
    
    var isCalculated: Bool { get }
    var mean: Double { get }
    var median: Double { get }
    var lowCount: Int { get }
    var highCount: Int { get }
    var normalCount: Int { get }
    var lowPercentage: Float { get }
    var highPercentage: Float { get }
    var normalPercentage: Float { get }
    var a1cIFCC: Double { get }
    var a1cDCCT: Double { get }
    var stdDev: Double { get }
    var relativeSD: Double { get }
    var gvi: Double { get }
    var pgs: Double { get }
}

final class StatsRootCalculationWorker: StatsRootCalculationWorkerLogic {
    var isCalculated = false
    var mean: Double = 0.0
    var median: Double = 0.0
    var lowCount: Int = 0
    var highCount: Int = 0
    var normalCount: Int = 0
    var lowPercentage: Float = 0.0
    var highPercentage: Float = 0.0
    var normalPercentage: Float = 0.0
    var a1cIFCC: Double = 0.0
    var a1cDCCT: Double = 0.0
    var stdDev: Double = 0.0
    var relativeSD: Double = 0.0
    var gvi: Double = 0.0
    var pgs: Double = 0.0
    
    func calculate(with readings: [BaseGlucoseReading], lowThreshold: Double, highThreshold: Double) {
        let nonZero = readings
        guard !nonZero.isEmpty else { isCalculated = false; return }
        
        lowCount = nonZero.filter { $0.filteredCalculatedValue < lowThreshold }.count
        highCount = nonZero.filter { $0.filteredCalculatedValue > highThreshold }.count
        normalCount = nonZero.count - lowCount - highCount
        
        lowPercentage = (Float(lowCount) / Float(nonZero.count) * 100.0)
        highPercentage = (Float(highCount) / Float(nonZero.count) * 100.0)
        normalPercentage = (Float(normalCount) / Float(nonZero.count) * 100.0)
        
        let values = nonZero.map { $0.filteredCalculatedValue }
        mean = values.reduce(0.0, +) / Double(values.count)
        
        let sorted = values.sorted()
        if sorted.count.isMultiple(of: 2) {
            if values.count == 2 {
                median = (values[0] + values[1]) / 2.0
            } else {
                median = (values[sorted.count / 2] + values[sorted.count / 2 + 1]) / 2.0
            }
        } else {
            let index = (sorted.count - 1) / 2 + 1
            if index < values.count {
                median = values[index]
            } else {
                median = values[0]
            }
        }
        
        a1cIFCC = ((mean + 46.7) / 28.7 - 2.15) * 10.929
        a1cDCCT = (10.0 * (mean + 46.7) / 28.7).rounded() / 10.0
        
        stdDev = sqrt(nonZero.reduce(0, {
            $0 + ($1.filteredCalculatedValue - mean) * ($1.filteredCalculatedValue - mean) / Double(nonZero.count)
        }))
        relativeSD = (1000.0 * stdDev / mean).rounded() / 10.0
        let pass1Data = pass1DataCleaning(readings)
        let normalized = pass2DataCleaning(pass1Data)
        guard !normalized.isEmpty else { isCalculated = true; return }
        
        let glucoseFirst = normalized[0].filteredCalculatedValue
        var glucoseLast = glucoseFirst
        var glucoseTotal = glucoseLast
        var gviTotal = 0.0
        var usedRecords = 1
        
        for index in 1..<normalized.count {
            let reading = normalized[index]
            let delta = reading.filteredCalculatedValue - glucoseLast
            gviTotal += sqrt(25.0 + pow(delta, 2.0))
            usedRecords += 1
            glucoseLast = reading.filteredCalculatedValue
            glucoseTotal += glucoseLast
        }
        
        let gviDelta = abs(glucoseLast - glucoseFirst)
        let gviIdeal = sqrt(pow(Double(usedRecords) * 5.0, 2.0) + pow(gviDelta, 2.0))
        gvi = (gviTotal / gviIdeal * 100.0) / 100.0
        let glucoseMean = floor(glucoseTotal / Double(usedRecords))
        let tirMultiplier = Double(normalPercentage / 100.0)
        pgs = (gvi * glucoseMean * (1.0 - tirMultiplier) * 100.0) / 100.0
        
        isCalculated = true
    }
    
    private func pass1DataCleaning(_ readings: [BaseGlucoseReading]) -> [BaseGlucoseReading] {
        guard readings.count > 1 else { return readings }
        
        var glucoseData: [BaseGlucoseReading] = []
        for index in 0..<readings.count - 1 {
            let entry = readings[index]
            let nextEntry = readings[index + 1]
            
            guard let date1 = entry.date, let date2 = nextEntry.date else { continue }
            
            let timeDelta = date2.timeIntervalSince1970 - date1.timeIntervalSince1970
            if timeDelta < 9.0 * .secondsPerMinute || timeDelta > 25.0 * .secondsPerMinute {
                glucoseData.append(entry)
                continue
            }
            
            let missingRecords = Int(floor(timeDelta / (5.0 * .secondsPerMinute * 0.99)) - 1)
            let timePatch = Int(floor(timeDelta / Double(missingRecords + 1)))
            let delta = (nextEntry.filteredCalculatedValue - entry.filteredCalculatedValue) / Double(missingRecords + 1)
            glucoseData.append(entry)
            
            for index2 in 1...missingRecords {
                let newEntry = LightGlucoseReading()
                newEntry.setFilteredCalculatedValue(entry.filteredCalculatedValue + delta * Double(index2))
                newEntry.setDate(date1 + Double(index2) * Double(timePatch))
                glucoseData.append(newEntry)
            }
        }
        
        return glucoseData
    }
    
    private func pass2DataCleaning(_ glucoseData: [BaseGlucoseReading]) -> [BaseGlucoseReading] {
        guard glucoseData.count > 2 else { return glucoseData }
       
        var glucoseData2: [BaseGlucoseReading] = []
        var previousEntry: BaseGlucoseReading?
        
        if !glucoseData.isEmpty {
            glucoseData2.append(glucoseData[0])
            previousEntry = glucoseData[0]
        }
        
        for index in 1..<glucoseData.count - 2 {
            let entry = glucoseData[index]
            let nextEntry = glucoseData[index + 1]
            
            guard let date1 = entry.date, let date2 = nextEntry.date else { continue }
            guard let prevEntry = previousEntry else { continue }
            guard let prevDate = prevEntry.date else { continue }
            
            let timeDelta = date2.timeIntervalSince1970 - date1.timeIntervalSince1970
            let timeDelta2 = date1.timeIntervalSince1970 - prevDate.timeIntervalSince1970
            let maxGap = 5.0 * .secondsPerMinute + 20.0
            
            if timeDelta > maxGap || timeDelta2 > maxGap {
                glucoseData2.append(entry)
                previousEntry = entry
                continue
            }
            
            let delta1 = entry.filteredCalculatedValue - prevEntry.filteredCalculatedValue
            let delta2 = nextEntry.filteredCalculatedValue - entry.filteredCalculatedValue
            
            if delta1 <= 8.0 && delta2 <= 8.0 {
                glucoseData2.append(entry)
                previousEntry = entry
                continue
            }
            
            if (delta1 > 0.0 && delta2 < 0.0) || (delta1 < 0.0 && delta2 > 0.0) {
                let delta = (nextEntry.filteredCalculatedValue - prevEntry.filteredCalculatedValue) / 2.0
                let newEntry = LightGlucoseReading()
                newEntry.setFilteredCalculatedValue(prevEntry.filteredCalculatedValue + delta)
                newEntry.setDate(date1)
                
                glucoseData2.append(newEntry)
                previousEntry = newEntry
                continue
            }
            
            glucoseData2.append(entry)
            previousEntry = entry
        }
        
        return glucoseData2
    }
}

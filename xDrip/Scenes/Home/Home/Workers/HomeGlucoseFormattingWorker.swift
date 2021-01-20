//
//  HomeGlucoseFormattingWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

 struct HomeGlucoseEntry: GlucoseChartGlucoseEntry {
    let value: Double
    let date: Date
    let severity: GlucoseChartSeverityLevel
}

private struct HomeGlucoseCurrentInfoEntry: GlucoseCurrentInfoEntry {
    let glucoseIntValue: String
    let glucoseDecimalValue: String
    let slopeValue: String
    let lastScanDate: String
    let difValue: String
    let severityColor: UIColor?
    let isOutdated: Bool
    
    static var emptyEntry: HomeGlucoseCurrentInfoEntry {
        return HomeGlucoseCurrentInfoEntry(
        glucoseIntValue: "-",
        glucoseDecimalValue: "-",
        slopeValue: "-",
        lastScanDate: "--",
        difValue: "--",
        severityColor: nil,
        isOutdated: false)
    }
}

private struct HomeBasalEntry: BasalChartBasalEntry {
    let value: Double
    let date: Date
}

protocol HomeGlucoseFormattingWorkerProtocol {
    func formatEntries(_ entries: [GlucoseChartEntry]) -> [GlucoseChartGlucoseEntry]
    func formatEntry(_ entry: GlucoseChartEntry?) -> GlucoseCurrentInfoEntry
    func formatEntries(_ entries: [InsulinEntry]) -> [BasalChartBasalEntry]
    func formatDataSection(_ entries: [GlucoseChartEntry]) -> Home.DataSectionViewModel
}

final class HomeGlucoseFormattingWorker: HomeGlucoseFormattingWorkerProtocol {
    private let statsCalculationWorker: StatsRootCalculationWorkerLogic
    
    init() {
        statsCalculationWorker = StatsRootCalculationWorker()
    }
    
    func formatEntries(_ entries: [GlucoseChartEntry]) -> [GlucoseChartGlucoseEntry] {
        let settings = User.current.settings
        return entries.map {
            HomeGlucoseEntry(
                value: GlucoseUnit.convertFromDefault($0.filteredCalculatedValue),
                date: $0.date ?? Date(),
                severity: GlucoseChartSeverityLevel(
                    warningLevel: settings?.warningLevel(forValue: $0.filteredCalculatedValue)
                )
            )
        }
    }
    
    func formatEntry(_ entry: GlucoseChartEntry?) -> GlucoseCurrentInfoEntry {
        guard let entry = entry else {
            return HomeGlucoseCurrentInfoEntry.emptyEntry
        }
        let components = getComponentsForGlucoseValue(GlucoseUnit.convertFromDefault(
            entry.filteredCalculatedValue) )
        let glucoseIntValue = components.first ?? "-"
        let glucoseDecimalValue = components.last ?? "-"
        
        let diff: Double
        let last2Readings = GlucoseChartEntry.lastReadings(2, for: entry.deviceMode)
        if last2Readings.count < 2 {
            diff = 0.0
        } else {
            diff = last2Readings[0].calculatedValue - last2Readings[1].calculatedValue
        }
        
        let slopeValue = slopeToArrowSymbol(slope: entry.calculatedValueSlope * 60.0)
        var lastScanDate: String
        if let date = entry.date {
            lastScanDate = getLastScanDateStringFrom(date: date)
        } else {
            lastScanDate = "--"
        }
        
        let difValue = getDeltaString(GlucoseUnit.convertFromDefault(diff))
        let settings = User.current.settings
        let severity = GlucoseChartSeverityLevel(
                           warningLevel: settings?.warningLevel(forValue: entry.filteredCalculatedValue))
        let color = UIColor.colorForSeverityLevel(severity)
        var isOutdated: Bool
        if let entryDate = entry.date {
            isOutdated = Date().timeIntervalSince1970 - entryDate.timeIntervalSince1970 >= TimeInterval(minutes: 11)
        } else {
            isOutdated = false
        }
        return HomeGlucoseCurrentInfoEntry(
            glucoseIntValue: glucoseIntValue,
            glucoseDecimalValue: glucoseDecimalValue,
            slopeValue: slopeValue,
            lastScanDate: lastScanDate,
            difValue: difValue,
            severityColor: color,
            isOutdated: isOutdated)
    }
    
    func formatEntries(_ entries: [InsulinEntry]) -> [BasalChartBasalEntry] {
        return entries.compactMap { entry -> HomeBasalEntry? in
            guard entry.type == .basal else { return nil }
            return HomeBasalEntry(
                value: entry.amount,
                date: entry.date ?? Date()
            )
        }
    }
    
    func formatDataSection(_ entries: [GlucoseChartEntry]) -> Home.DataSectionViewModel {
         let isShown = User.current.settings.chart?.showData ?? true
        guard !entries.isEmpty else {
            return Home.DataSectionViewModel(
                lowValue: "N/A",
                lowTitle: "Low",
                inRange: "N/A",
                highValue: "N/A",
                highTitle: "High",
                avgGlucose: "N/A",
                a1c: "N/A",
                reading: "N/A",
                stdDeviation: "N/A",
                gvi: "N/A",
                pgs: "N/A",
                isShown: isShown
            )
        }
        let lowThresholdValue = User.current.settings.warningLevelValue(for: .low)
        let convertedLow = GlucoseUnit.convertFromDefault(lowThresholdValue)
        let highThresholdValue = User.current.settings.warningLevelValue(for: .high)
        let convertedHigh = GlucoseUnit.convertFromDefault(highThresholdValue)
        let unit = User.current.settings.unit.label
        
        statsCalculationWorker.calculate(
            with: entries,
            lowThreshold: lowThresholdValue,
            highThreshold: highThresholdValue
        )
        
        let avgGlucose = GlucoseUnit.convertFromDefault(statsCalculationWorker.mean)
        let stdDeviation = GlucoseUnit.convertFromDefault(statsCalculationWorker.stdDev)
        
        return Home.DataSectionViewModel(
            lowValue: String(format: "%0.1f%%", statsCalculationWorker.lowPercentage),
            lowTitle: String(format: "Low (<%0.1f)", convertedLow),
            inRange: String(format: "%0.1f%%", statsCalculationWorker.normalPercentage),
            highValue: String(format: "%0.1f%%", statsCalculationWorker.highPercentage),
            highTitle: String(format: "High (>%0.1f)", convertedHigh),
            avgGlucose: String(format: "%0.1f \(unit)", avgGlucose),
            a1c: String(format: "%0.1f%%", statsCalculationWorker.a1cDCCT),
            reading: "\(entries.count)",
            stdDeviation: String(format: "%0.1f \(unit)", stdDeviation),
            gvi: String(format: "%0.2f", statsCalculationWorker.gvi),
            pgs: String(format: "%0.2f", statsCalculationWorker.pgs),
            isShown: isShown
        )
    }
    
    private func getComponentsForGlucoseValue(_ glucoseValue: Double) -> [String] {
        let roundedGlucoseValueString = getRoundedStringFrom(glucoseValue, place: 1)
        return roundedGlucoseValueString.components(separatedBy: ".")
    }
    
    private func getRoundedStringFrom(_ value: Double, place: Int) -> String {
        return String(format: "%.\(place)f", value.rounded(to: place))
    }
    
    private func getDeltaString(_ value: Double) -> String {
        let unit = User.current.settings.unit
        var valueString: String
        if value.rounded(to: 2).isZero {
            valueString = getRoundedStringFrom(abs(value), place: 1)
        } else if abs(value) < 0.1 || unit == .mmolL {
            valueString = getRoundedStringFrom(value, place: 2)
        } else {
            valueString = getRoundedStringFrom(value, place: 1)
        }
        let signString = value > 0 ? "+" : ""
        let unitString = unit.label
        return signString + valueString + " " + unitString
    }
    
    private func slopeToArrowSymbol(slope: Double) -> String {
        if slope <= -3.5 {
            return "\u{21ca}"// ⇊
        } else if slope <= -2 {
            return "\u{2193}" // ↓
        } else if slope <= -1 {
            return "\u{2198}" // ↘
        } else if slope <= 1 {
            return "\u{2192}" // →
        } else if slope <= 2 {
            return "\u{2197}" // ↗
        } else if slope <= 3.5 {
            return "\u{2191}" // ↑
        } else {
            return "\u{21c8}" // ⇈
        }
    }
    
    private func getLastScanDateStringFrom(date: Date) -> String {
        return DateFormatter.localizedString(
            from: date,
            dateStyle: Calendar.current.isDateInToday(date) ? .none : .short,
            timeStyle: .short)
    }
}

fileprivate extension GlucoseChartSeverityLevel {
    init(warningLevel: GlucoseWarningLevel?) {
        guard let level = warningLevel else { self = .normal; return }
        switch level {
        case .low, .high: self = .abnormal
        case .urgentHigh, .urgentLow: self = .critical
        }
    }
}

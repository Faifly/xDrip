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

private struct HomeGlucoseEntry: GlucoseChartGlucoseEntry {
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
    
    static var emptyEntry: HomeGlucoseCurrentInfoEntry {
        return HomeGlucoseCurrentInfoEntry(
        glucoseIntValue: "-",
        glucoseDecimalValue: "-",
        slopeValue: "-",
        lastScanDate: "--",
        difValue: "--",
        severityColor: nil)
    }
}

private struct HomeBasalEntry: BasalChartEntry {
    let value: Double
    let date: Date
}

protocol BasalChartEntry {
    var value: Double { get }
    var date: Date { get }
}

protocol HomeGlucoseFormattingWorkerProtocol {
    func formatEntries(_ entries: [GlucoseReading]) -> [GlucoseChartGlucoseEntry]
    func formatEntry(_ entry: GlucoseReading?) -> GlucoseCurrentInfoEntry
    func formatEntries(_ entries: [InsulinEntry]) -> [BasalChartEntry]
}

final class HomeGlucoseFormattingWorker: HomeGlucoseFormattingWorkerProtocol {
    func formatEntries(_ entries: [GlucoseReading]) -> [GlucoseChartGlucoseEntry] {
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
    
    func formatEntry(_ entry: GlucoseReading?) -> GlucoseCurrentInfoEntry {
        guard let entry = entry else {
            return HomeGlucoseCurrentInfoEntry.emptyEntry
        }
        let components = getComponentsForGlucoseValue(GlucoseUnit.convertToUserDefined(
            entry.filteredCalculatedValue) )
        let glucoseIntValue = components.first ?? "-"
        let glucoseDecimalValue = components.last ?? "-"
        let slopeValue = slopeToArrowSymbol(slope: entry.activeSlope() )
        var lastScanDate: String
        if let date = entry.date {
            lastScanDate = getLastScanDateStringFrom(date: date)
        } else {
            lastScanDate = "--"
        }
        let difValue = getDeltaString(entry.calculatedValueSlope)
        let settings = User.current.settings
        let severity = GlucoseChartSeverityLevel(
                           warningLevel: settings?.warningLevel(forValue: entry.filteredCalculatedValue))
        let color = UIColor.colorForSeverityLevel(severity)
        return HomeGlucoseCurrentInfoEntry(
            glucoseIntValue: glucoseIntValue,
            glucoseDecimalValue: glucoseDecimalValue,
            slopeValue: slopeValue,
            lastScanDate: lastScanDate,
            difValue: difValue,
            severityColor: color)
    }
    
    func formatEntries(_ entries: [InsulinEntry]) -> [BasalChartEntry] {
        return entries.compactMap { entry -> HomeBasalEntry? in
            guard entry.type == .basal else { return nil }
            return HomeBasalEntry(
                value: entry.amount,
                date: entry.date ?? Date()
            )
        }
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
        } else if abs(value) < 0.1 {
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

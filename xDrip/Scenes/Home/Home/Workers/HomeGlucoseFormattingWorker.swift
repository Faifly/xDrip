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

fileprivate struct HomeGlucoseEntry: GlucoseChartGlucoseEntry {
    let value: Double
    let date: Date
    let severity: GlucoseChartSeverityLevel
}

protocol HomeGlucoseFormattingWorkerProtocol {
    func formatEntries(_ entries: [GlucoseReading]) -> [GlucoseChartGlucoseEntry]
}

final class HomeGlucoseFormattingWorker: HomeGlucoseFormattingWorkerProtocol {
    func formatEntries(_ entries: [GlucoseReading]) -> [GlucoseChartGlucoseEntry] {
        let settings = User.current.settings
        return entries.map {
            HomeGlucoseEntry(
                value: GlucoseUnit.convertToUserDefined($0.filteredCalculatedValue),
                date: $0.date ?? Date(),
                severity: GlucoseChartSeverityLevel(warningLevel: settings?.warningLevel(forValue: $0.filteredCalculatedValue))
            )
        }
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

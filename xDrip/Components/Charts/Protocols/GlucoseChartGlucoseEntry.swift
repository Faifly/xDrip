//
//  GlucoseChartGlucoseEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 16.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum GlucoseChartSeverityLevel {
    case normal
    case abnormal
    case critical
}

protocol GlucoseChartGlucoseEntry {
    var value: Double { get }
    var date: Date { get }
    var severity: GlucoseChartSeverityLevel { get }
}

protocol GlucoseCurrentInfoEntry {
    var glucoseValue: Double { get }
    var slopeValue: Double { get }
    var lastScanDate: Date { get }
    var difValue: Double { get }
}

//
//  GlucoseChartGlucoseEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 16.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum GlucoseChartSeverityLevel {
    case low
    case normal
    case high
}

protocol GlucoseChartGlucoseEntry {
    var value: Double { get }
    var date: Date { get }
    var severity: GlucoseChartSeverityLevel { get }
}

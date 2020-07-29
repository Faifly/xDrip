//
//  MockedEntries.swift
//  xDrip
//
//  Created by Dmitry on 29.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

 enum MockedEntries {
    static let glucoseEntries: [HomeGlucoseEntry] = [
        HomeGlucoseEntry(
            value: 62,
            date: Date() - 2000,
            severity: GlucoseChartSeverityLevel.normal
        ),
        HomeGlucoseEntry(
            value: 60,
            date: Date() - 1000,
            severity: GlucoseChartSeverityLevel.normal
        ),
        HomeGlucoseEntry(
            value: 61,
            date: Date(),
            severity: GlucoseChartSeverityLevel.normal
        )
    ]
    
    static let entries = [
        InsulinEntry(amount: 62, date: Date() - 2000, type: .bolus),
        InsulinEntry(amount: 60, date: Date() - 1000, type: .bolus),
        InsulinEntry(amount: 61, date: Date(), type: .bolus)
    ]
}

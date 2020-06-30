//
//  CGlucoseReading.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct CGlucoseReading: Codable {
    let identifier: String?
    let type: String?
    let date: Int64?
    let sgv: Double?
    let filtered: Double?
    let unfiltered: Double?
    
    init(reading: GlucoseReading) {
        identifier = reading.externalID
        type = "sgv"
        date = Int64((reading.date?.timeIntervalSince1970 ?? 0.0) * 1000.0)
        sgv = reading.calculatedValue.rounded(to: 2)
        filtered = reading.rawValue.rounded(to: 2)
        unfiltered = reading.filteredValue.rounded(to: 2)
    }
}

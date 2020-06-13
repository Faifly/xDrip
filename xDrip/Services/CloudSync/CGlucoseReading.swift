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
    let sgv: Int?
    
    init(reading: GlucoseReading) {
        identifier = reading.externalID
        type = "sgv"
        date = Int64((reading.date?.timeIntervalSince1970 ?? 0.0) * 1000.0)
        sgv = Int(reading.calculatedValue.rounded())
    }
}

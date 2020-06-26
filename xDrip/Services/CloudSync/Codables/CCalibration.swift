//
//  CCalibration.swift
//  xDrip
//
//  Created by Artem Kalmykov on 25.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct CCalibration: Codable {
    let identifier: String?
    let type: String?
    let date: Int64?
    let mbg: Double
    let device: String?
    
    init(calibration: Calibration) {
        identifier = calibration.externalID
        type = "mbg"
        date = Int64((calibration.date?.timeIntervalSince1970 ?? 0.0) * 1000.0)
        mbg = calibration.glucoseLevel.rounded(to: 2)
        device = "xDrip iOS"
    }
}

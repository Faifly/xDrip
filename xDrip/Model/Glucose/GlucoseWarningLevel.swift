//
//  GlucoseWarningLevel.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum GlucoseWarningLevel: Int {
    case urgentLow
    case low
    case high
    case urgentHigh
    
    var defaultValue: Double {
        switch self {
        case .urgentLow: return 55.0
        case .low: return 70.0
        case .high: return 170.0
        case .urgentHigh: return 200.0
        }
    }
}

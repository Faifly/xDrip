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
        case .urgentLow: return 3.5
        case .low: return 4.2
        case .high: return 9.5
        case .urgentHigh: return 11.0
        }
    }
}

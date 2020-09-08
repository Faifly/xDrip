//
//  TrainingIntensity.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum TrainingIntensity: Int, CaseIterable {
    case low
    case normal
    case high
    
    static var `default`: TrainingIntensity {
        return .normal
    }
    
    func paramValue() -> String {
        switch self {
        case .low:
            return "low"
        case .normal:
            return "moderate"
        case .high:
            return "high"
        }
    }
    
    static func getValue(paramValue: String) -> TrainingIntensity {
        switch paramValue {
        case "low":
            return TrainingIntensity.low
        case "moderate":
            return TrainingIntensity.normal
        case "high":
            return TrainingIntensity.high
        default:
            return TrainingIntensity.default
        }
    }
}

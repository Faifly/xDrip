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
    
    var paramValue: String {
        switch self {
        case .low:
            return "low"
        case .normal:
            return "moderate"
        case .high:
            return "high"
        }
    }
    
    init(paramValue: String) {
        switch paramValue {
        case "low":
            self = .low
        case "moderate":
            self = .normal
        case "high":
            self = .high
        default:
            self = .default
        }
    }
}

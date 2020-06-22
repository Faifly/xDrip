//
//  AlertEventType.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum AlertEventType: Int, CaseIterable {
    case `default`
    case fastRise
    case urgentHigh
    case high
    case fastDrop
    case low
    case urgentLow
    case missedReadings
    case phoneMuted
    case calibrationRequest
    case initialCalibrationRequest
    case pairingRequest
    
    var requiresGlucoseThreshold: Bool {
        switch self {
        case .default,
             .missedReadings,
             .phoneMuted,
             .calibrationRequest,
             .initialCalibrationRequest,
             .pairingRequest,
             .urgentHigh,
             .high,
             .low,
             .urgentLow:
            return false
            
        case .fastRise,
             .fastDrop:
            return true
        }
    }
    
    var requiresGlucoseWarningLevel: Bool {
        switch self {
        case .default,
             .missedReadings,
             .phoneMuted,
             .calibrationRequest,
             .initialCalibrationRequest,
             .pairingRequest,
             .fastRise,
             .fastDrop:
            return false
        case .urgentHigh,
             .high,
             .low,
             .urgentLow:
            return true
        }
    }
}

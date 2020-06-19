//
//  AlertEventType+Data.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension AlertEventType {
    var alertTitle: String {
        switch self {
        case .pairingRequest: return "notification_pairing_request_title".localized
        case .initialCalibrationRequest: return "notification_initial_calibration_title".localized
        case .default: return "default alert"
        case .fastRise: return "fast rise alert"
        case .urgentHigh: return "urgent high"
        case .high: return "high alert"
        case .fastDrop: return "fast drop alert"
        case .low: return "low alert"
        case .urgentLow: return "urgent low alert"
        case .missedReadings: return "missed readings alert"
        case .phoneMuted: return "phone muted alert"
        case .calibrationRequest: return "calibration request alert"
        }
    }
    
    var alertBody: String {
        switch self {
        case .pairingRequest: return "notification_pairing_request_body".localized
        case .initialCalibrationRequest: return "notification_initial_calibration_body".localized
        case .default: return "default body"
        case .fastRise: return "fast rise body"
        case .urgentHigh: return "urgent high body"
        case .high: return "high body"
        case .fastDrop: return "fast drop body"
        case .low: return "low body"
        case .urgentLow: return "urgent low body"
        case .missedReadings: return "missed readings body"
        case .phoneMuted: return "phone muted body"
        case .calibrationRequest: return "calibration request body"
        }
    }
    
    var alertID: String {
        switch self {
        case .pairingRequest: return "pairingRequest"
        case .initialCalibrationRequest: return "initialCalibration"
        case .default: return "defaultAlertID"
        case .fastRise: return "glucoseFastRise"
        case .urgentHigh: return "glucoseUrgentHigh"
        case .high: return "glucoseHigh"
        case .fastDrop: return "glucoseFastDrop"
        case .low: return "glucoseLow"
        case .urgentLow: return "glucoseUrgentLow"
        case .missedReadings: return "missedReadings"
        case .phoneMuted: return "phoneMuted"
        case .calibrationRequest: return "calibrationRequest"
        }
    }
}

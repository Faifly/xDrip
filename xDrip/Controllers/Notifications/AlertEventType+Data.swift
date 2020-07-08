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
        case .fastRise: return "notification_fast_rise_title".localized
        case .urgentHigh: return "notification_urgent_high_title".localized
        case .high: return "notification_high_title".localized
        case .fastDrop: return "notification_fast_drop_title".localized
        case .low: return "notification_low_title".localized
        case .urgentLow: return "notification_urgent_low_title".localized
        case .missedReadings: return "notification_missed_readings_title".localized
        case .phoneMuted: return "notification_phone_muted_title".localized
        case .calibrationRequest: return "Calibration Request"
        }
    }
    
    var alertBody: String {
        switch self {
        case .pairingRequest: return "notification_pairing_request_body".localized
        case .initialCalibrationRequest: return "notification_initial_calibration_body".localized
        case .default: return "default body"
        case .fastRise: return "notification_fast_rise_body".localized
        case .urgentHigh: return "notification_urgent_high_body".localized
        case .high: return "notification_high_body".localized
        case .fastDrop: return "notification_fast_drop_body".localized
        case .low: return "notification_low_body".localized
        case .urgentLow: return "notification_urgent_low_body".localized
        case .missedReadings: return "notification_missed_readings_body".localized
        case .phoneMuted: return "notification_phone_muted_body".localized
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

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
        default: return ""
        }
    }
    
    var alertBody: String {
        switch self {
        case .pairingRequest: return "notification_pairing_request_body".localized
        case .initialCalibrationRequest: return "notification_initial_calibration_body".localized
        default: return ""
        }
    }
    
    var alertID: String {
        switch self {
        case .pairingRequest: return "pairingRequest"
        case .initialCalibrationRequest: return "initialCalibration"
        default: return ""
        }
    }
}

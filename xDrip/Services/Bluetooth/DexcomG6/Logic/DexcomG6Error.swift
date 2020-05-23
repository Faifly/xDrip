//
//  DexcomG6Error.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum DexcomG6Error: LocalizedError {
    case invalidSerial
    case invalidAuthRequestRx
    case invalidAuthChallengeRx
    case notAuthenticated
    case notPaired
    case invalidPairRequestRx
    case invalidSensorDataRx
    case invalidTransmitterVersionRx
    case invalidBatteryStatusRx
    case invalidTransmitterTimeRx
    
    var errorDescription: String? {
        switch self {
        case .invalidSerial: return "dexcom_error_invalid_serial".localized
        case .invalidAuthRequestRx: return "dexcom_error_invalid_auth_request_response".localized
        case .invalidAuthChallengeRx: return "dexcom_error_invalid_auth_challenge_response".localized
        case .notAuthenticated: return "dexcom_error_not_authed".localized
        case .notPaired: return "dexcom_error_not_paired".localized
        case .invalidPairRequestRx: return "dexcom_error_invalid_pair_request_response".localized
        case .invalidSensorDataRx: return "dexcom_error_invalid_sensor_data_response".localized
        case .invalidTransmitterVersionRx: return "dexcom_error_invalid_transmitter_version_response".localized
        case .invalidBatteryStatusRx: return "dexcom_error_invalid_battery_status_response".localized
        case .invalidTransmitterTimeRx: return "dexcom_error_invalid_transmitter_time_response".localized
        }
    }
}

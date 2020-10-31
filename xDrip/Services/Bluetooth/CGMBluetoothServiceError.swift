//
//  CGMBluetoothServiceError.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum CGMBluetoothServiceError: LocalizedError {
    case unknown
    case bluetoothIsPoweredOff
    case bluetoothIsUnauthorized
    case bluetoothUnsupported
    case peerRemovedPairingInformation
    case deviceSpecific(error: LocalizedError)
    
    var errorDescription: String? {
        switch self {
        case .unknown: return "bluetooth_error_unknown".localized
        case .bluetoothIsPoweredOff: return "bluetooth_error_powered_off".localized
        case .bluetoothIsUnauthorized: return "bluetooth_error_unauthorized".localized
        case .bluetoothUnsupported: return "bluetooth_error_unsupported".localized
        case .peerRemovedPairingInformation: return "bluetooth_error_removed_pairing_info".localized
        case .deviceSpecific(let error): return error.localizedDescription
        }
    }
}

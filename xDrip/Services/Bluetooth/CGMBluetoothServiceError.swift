//
//  CGMBluetoothServiceError.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum CGMBluetoothServiceError: Error {
    case unknown
    case bluetoothIsPoweredOff
    case bluetoothIsUnauthorized
    case bluetoothUnsupported
    case deviceSpecific(error: Error)
}

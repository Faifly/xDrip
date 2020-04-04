//
//  DexcomG6Error.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum DexcomG6Error: Error {
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
}

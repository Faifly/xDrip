//
//  DexcomG6CalibrationResponseType.swift
//  xDrip
//
//  Created by Dmitry on 29.12.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum DexcomG6CalibrationResponseType: UInt8 {
    case okay = 0x00
    case codeOne = 0x01
    case secondCalibrationNeeded = 0x06
    case rejected = 0x08
    case sensorStopped = 0x0B
    case duplicate = 0x0D
    case notReady = 0x0E
    case unableToDecode = 0xFF
}

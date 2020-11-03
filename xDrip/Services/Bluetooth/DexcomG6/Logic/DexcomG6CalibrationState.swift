//
//  DexcomG6CalibrationState.swift
//  xDrip
//
//  Created by Ivan Skoryk on 02.11.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum DexcomG6CalibrationState: UInt8 {
    case unknown = 0x00
    case stopped = 0x01
    case warmingUp = 0x02
    case excessNoise = 0x03
    case needsFirstCalibration = 0x04
    case needsSecondCalibration = 0x05
    case okay = 0x06
    case needsCalibration = 0x07
    case calibrationConfused = 0x08
    case calibrationConfused2 = 0x09
    case needsDifferentCalibration = 0x0a
    case sensorFailed = 0x0b
    case sensorFailed2 = 0x0c
    case unusualCalibration = 0x0d
    case insufficientCalibration = 0x0e
    case ended = 0x0f
    case sensorFailed3 = 0x10
    case transmitterProblem = 0x11
    case errors = 0x12
    case sensorFailed4 = 0x13
    case sensorFailed5 = 0x14
    case sensorFailed6 = 0x15
    case sensorFailedStart = 0x16
}

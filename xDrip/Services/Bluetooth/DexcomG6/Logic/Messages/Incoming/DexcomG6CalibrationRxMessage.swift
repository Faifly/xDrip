//
//  DexcomG6CalibrationRxMessage.swift
//  xDrip
//
//  Created by Dmitry on 29.12.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6CalibrationRxMessage {
    let type: DexcomG6CalibrationResponseType?
    
    init(data: Data) throws {
        guard data.count == 5 else { throw DexcomG6Error.invalidCalibrationRx }
        guard data[0] == DexcomG6OpCode.calibrateGlucoseRx.rawValue else { throw DexcomG6Error.invalidCalibrationRx }
        type = DexcomG6CalibrationResponseType(rawValue: data[2])
    }
    
    var accepted: Bool {
        return type == .okay || type == .secondCalibrationNeeded || type == .duplicate
    }
}

//
//  DexcomG6Firmware.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum DexcomG6Firmware {
    static func scaleRawValue(_ value: Double, firmware: String?) -> Double {
        guard let firmware = firmware else { return value }
        if firmware.starts(with: "1.") {
            return value * 34.0
        } else if firmware.starts(with: "2.") {
            return (value - 1151500000.0) / 110.0
        }
        
        return value
    }
    
    static func isResetSupported(_ firmware: String?) -> Bool {
        return firmware != "1.6.5.27"
    }
}

enum DexcomG6FirmwareVersion: Character {
    case first = "1"
    case second = "2"
}

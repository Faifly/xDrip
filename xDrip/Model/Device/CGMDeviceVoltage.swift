//
//  CGMDeviceVoltage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 21.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum CGMDeviceVoltage {
    case normal
    case low
    case critical
    
    init(value: Int) {
        switch value {
        case 0...270: self = .critical
        case 271...300: self = .low
        default: self = .normal
        }
    }
}

//
//  CGMDeviceType.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum CGMDeviceType: Int {
    case dexcomG6
    case mocked
    
    var warmUpInterval: TimeInterval {
        switch self {
        case .dexcomG6, .mocked: return .secondsPerHour * 2.0
        }
    }
}

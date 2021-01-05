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
    
    var title: String {
        switch self {
        case .dexcomG6: return "DexcomG6"
        case .mocked: return "Mocked"
        }
    }
    
    var prefix: String {
        switch self {
        case .dexcomG6: return "Dexcom"
        case .mocked: return "Mocked"
        }
    }
    
    var keepAliveSeconds: UInt8 {
        switch self {
        case .dexcomG6, .mocked: return 60
        }
    }

    var warmUpInterval: TimeInterval {
        switch self {
        case .dexcomG6, .mocked: return .secondsPerHour * 2.0
        }
    }
}

//
//  CGMDeviceResistance.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum CGMDeviceResistance {
    case normal
    case notice
    case critical
    
    init(value: Int) {
        switch value {
        case 0...750: self = .normal
        case 750...1400: self = .notice
        default: self = .critical
        }
    }
}

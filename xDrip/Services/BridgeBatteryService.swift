//
//  BridgeBatteryService.swift
//  xDrip
//
//  Created by Ivan Skoryk on 29.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import UIKit

enum BridgeBatteryService {
    static func getBatteryLevel() -> Double {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        let level = Double(device.batteryLevel) * 100.0
        device.isBatteryMonitoringEnabled = false
        return (level * 100.0).rounded() / 100.0
    }
}

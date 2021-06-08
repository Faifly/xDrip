//
//  CGMDeviceMetadataType.swift
//  xDrip
//
//  Created by Artem Kalmykov on 02.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum CGMDeviceMetadataType: Int {
    case firmwareVersion
    case transmitterVersion
    case batteryVoltageA
    case batteryVoltageB
    case batteryResistance
    case batteryTemperature
    case batteryRuntime
    case transmitterTime
    case sensorAge
    case lastSensorAge
    case serialNumber
    case deviceName
    
    var updateInterval: TimeInterval {
        return 3600.0
    }
}

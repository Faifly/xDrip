//
//  DexcomG6Constants.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum DexcomG6Constants {
    static let advertisementServiceID = "0000FEBC-0000-1000-8000-00805F9B34FB"
    static let serviceID = "F8083532-849E-531C-C594-30F1F86A4EA5"
    static let writeCharacteristicID = "F8083534-849E-531C-C594-30F1F86A4EA5"
    static let notifyCharacteristicID = "F8083535-849E-531C-C594-30F1F86A4EA5"
    static let backfillCharacteristicID = "F8083536-849E-531C-C594-30F1F86A4EA5"

    static let minimumReconnectionDelay: TimeInterval = 60.0
    static let batteryUpdateInterval: TimeInterval = 3600.0
}

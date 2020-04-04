//
//  CGMBluetoothServiceDelegate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 02.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol CGMBluetoothServiceDelegate: class {
    func serviceDidConnect()
    func serviceDidUpdateMetadata(_ metadata: CGMDeviceMetadataType, value: String)
    func serviceDidReceiveGlucoseReading(raw: Double, filtered: Double)
    func serviceDidFail(withError error: CGMBluetoothServiceError)
}

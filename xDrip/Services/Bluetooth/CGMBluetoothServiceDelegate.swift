//
//  CGMBluetoothServiceDelegate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 02.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol CGMBluetoothServiceDelegate: AnyObject {
    func serviceDidConnect()
    func serviceDidDisconnect()
    func serviceDidUpdateMetadata(_ metadata: CGMDeviceMetadataType, value: String)
    func serviceDidReceiveGlucoseReading(raw: Double, filtered: Double, rssi: Double)
    func serviceDidFail(withError error: CGMBluetoothServiceError)
}

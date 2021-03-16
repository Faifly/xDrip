//
//  CGMBluetoothServiceDelegate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 02.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol CGMBluetoothServiceDelegate: AnyObject {
    func serviceDidConnect(isPaired: Bool)
    func serviceDidDisconnect(isPaired: Bool)
    func serviceDidUpdateMetadata(_ metadata: CGMDeviceMetadataType, value: String)
    func serviceDidReceiveSensorGlucoseReading(raw: Double, filtered: Double, rssi: Double)
    func serviceDidReceiveGlucoseReading(calculatedValue: Double,
                                         calibrationState: DexcomG6CalibrationState?,
                                         date: Date,
                                         forBackfill: Bool)
    func serviceDidReceiveCalibrationResponse(type: DexcomG6CalibrationResponseType?)
    func serviceDidFail(withError error: CGMBluetoothServiceError)
}

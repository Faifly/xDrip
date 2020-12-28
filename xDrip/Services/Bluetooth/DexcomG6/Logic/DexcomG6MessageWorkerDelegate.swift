//
//  DexcomG6MessageWorkerDelegate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 31.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol DexcomG6MessageWorkerDelegate: AnyObject {
    func workerRequiresSendingOutgoingMessage(_ message: DexcomG6OutgoingMessage)
    func workerDidSuccessfullyAuthorize()
    func workerDidReceiveSensorData(_ message: DexcomG6SensorDataRxMessage)
    func workerDidReceiveGlucoseData(_ message: DexcomG6GlucoseDataRxMessage)
    func workerDidReceiveTransmitterInfo(_ message: DexcomG6TransmitterVersionRxMessage)
    func workerDidReceiveBatteryInfo(_ message: DexcomG6BatteryStatusRxMessage)
    func workerDidReceiveTransmitterTimeInfo(_ message: DexcomG6TransmitterTimeRxMessage)
    func workerDidRequestPairing()
    func workerDidReceiveGlucoseBackfillMessage(_ message: DexcomG6BackfillRxMessage)
    func workerDidReceiveBackfillData(_ backsies: [DexcomG6BackfillStream.Backsie])
}

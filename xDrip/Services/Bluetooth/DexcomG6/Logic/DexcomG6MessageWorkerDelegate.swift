//
//  DexcomG6MessageWorkerDelegate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 31.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol DexcomG6MessageWorkerDelegate: class {
    func workerRequiresSendingOutgoingMessage(_ message: DexcomG6OutgoingMessage)
    func workerDidSuccessfullyAuthorize()
    func workerDidReceiveReading(_ message: DexcomG6SensorDataRxMessage)
    func workerDidReceiveTransmitterInfo(_ message: DexcomG6TransmitterVersionRxMessage)
    func workerDidReceiveBatteryInfo(_ message: DexcomG6BatteryStatusRxMessage)
    func workerDidReceiveTransmitterTimeInfo(_ message: DexcomG6TransmitterTimeRxMessage)
}

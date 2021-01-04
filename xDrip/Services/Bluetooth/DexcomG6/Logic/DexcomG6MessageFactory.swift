//
//  DexcomG6MessageFactory.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class DexcomG6MessageFactory {
    func createOutgoingMessage(ofType type: DexcomG6OpCode) -> DexcomG6OutgoingMessage? {
        switch type {
        case .authRequestTx: return DexcomG6AuthRequestTxMessage()
        case .pairRequestTx: return DexcomG6PairRequestTxMessage()
        case .firmwareVersionTx: return DexcomG6FirmwareVersionTxMessage()
        case .transmitterVersionTx: return DexcomG6TransmitterVersionTxMessage()
        case .sensorDataTx: return DexcomG6SensorDataTxMessage()
        case .batteryStatusTx: return DexcomG6BatteryStatusTxMessage()
        case .transmitterTimeTx: return DexcomG6TransmitterTimeTxMessage()
        case .resetTx: return DexcomG6ResetTxMessage()
        case .keepAliveTx: return DexcomG6KeepAliveTxMessage(seconds: CGMDeviceType.dexcomG6.keepAliveSeconds)
        default: return nil
        }
    }
}

//
//  DexcomG6SessionStopRxMessage.swift
//  xDrip
//
//  Created by Dmitry on 22.03.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6SessionStopRxMessage {
    let status: UInt8
    let received: UInt8
    let sessionStopTime: Double
    let sessionStartTime: Double
    let transmitterTime: Double

    init(data: Data) throws {
        guard data[0] == DexcomG6OpCode.sessionStartRx.rawValue else { throw DexcomG6Error.invalidStartSensorDataRx }
        status = data[1]
        received = data[2]
        sessionStopTime = Double(Data(data[3..<7]).to(UInt32.self))
        sessionStartTime = Double(Data(data[7..<11]).to(UInt32.self))
        transmitterTime = Double(Data(data[11..<15]).to(UInt32.self))
        
        LogController.log(
            message: "[Dexcom G6] DexcomG6SessionStopRxMessage status: %@, received: %@, sessionStopTime: %@, sessionStartTime: %@, transmitterTime: %@",
            type: .debug,
            status.description,
            received.description,
            sessionStopTime.description,
            sessionStartTime.description,
            transmitterTime.description
        )
    }
}

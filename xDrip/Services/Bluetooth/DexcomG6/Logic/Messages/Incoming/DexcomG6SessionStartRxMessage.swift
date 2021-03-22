//
//  DexcomG6SessionStartRxMessage.swift
//  xDrip
//
//  Created by Dmitry on 08.01.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6SessionStartRxMessage {
    let status: UInt8
    let info: UInt8
    let requestedStartTime: Double
    let sessionStartTime: Double
    let transmitterTime: Double

    init(data: Data) throws {
        guard data[0] == DexcomG6OpCode.sessionStartRx.rawValue else { throw DexcomG6Error.invalidStartSensorDataRx }
        status = data[1]
        info = data[2]
        requestedStartTime = Double(Data(data[3..<7]).to(UInt32.self))
        sessionStartTime = Double(Data(data[7..<11]).to(UInt32.self))
        transmitterTime = Double(Data(data[11..<15]).to(UInt32.self))
        
        LogController.log(
            message: "[Dexcom G6] DexcomG6SessionStartRxMessage status: %@, info: %@, requestedStartTime: %@, sessionStartTime: %@, transmitterTime: %@",
            type: .debug,
            status.description,
            info.description,
            requestedStartTime.description,
            sessionStartTime.description,
            transmitterTime.description
        )
    }
}

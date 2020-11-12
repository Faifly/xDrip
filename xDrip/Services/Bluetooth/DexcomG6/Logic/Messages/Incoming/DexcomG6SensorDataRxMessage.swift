//
//  DexcomG6SensorDataRxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 31.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6SensorDataRxMessage {
    let status: UInt8
    let filtered: Double
    let unfiltered: Double

    init(data: Data) throws {
        guard data.count >= 14 else { throw DexcomG6Error.invalidSensorDataRx }
        guard data[0] == DexcomG6OpCode.sensorDataRx.rawValue else { throw DexcomG6Error.invalidSensorDataRx }

        status = data[1]
        let rawUnfiltered: UInt32 = Data(data[6..<10]).to(UInt32.self)
        unfiltered = Double(rawUnfiltered)
        let rawFiltered: UInt32 = Data(data[10..<14]).to(UInt32.self)
        filtered = Double(rawFiltered)
    }
}

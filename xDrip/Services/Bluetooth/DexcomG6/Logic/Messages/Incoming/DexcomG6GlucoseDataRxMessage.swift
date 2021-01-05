//
//  DexcomG6GlucoseDataRxMessage.swift
//  xDrip
//
//  Created by Dmitry on 25.12.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6GlucoseDataRxMessage {
    let status: UInt8
    let calculatedValue: Double

    init(data: Data) throws {
        guard data.count >= 14 else { throw DexcomG6Error.invalidSensorDataRx }
        guard data[0] == DexcomG6OpCode.glucoseRx.rawValue else { throw DexcomG6Error.invalidSensorDataRx }

        status = data[1]
        calculatedValue = Double(Data(data[10..<12]).to(UInt16.self) & 0xfff)
    }
}

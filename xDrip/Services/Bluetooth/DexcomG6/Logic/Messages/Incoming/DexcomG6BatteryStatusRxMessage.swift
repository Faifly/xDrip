//
//  DexcomG6BatteryStatusRxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 01.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6BatteryStatusRxMessage {
    let status: UInt8
    let voltageA: Int
    let voltageB: Int
    let resist: Int
    let runtime: Int
    let temperature: Int
    
    init(data: Data) throws {
        guard data.count >= 10 else { throw DexcomG6Error.invalidBatteryStatusRx }
        guard data[0] == DexcomG6OpCode.batteryStatusRx.rawValue else { throw DexcomG6Error.invalidBatteryStatusRx }
        
        status = data[1]
        voltageA = Int(data.subdata(in: 2..<4).to(Int16.self))
        voltageB = Int(data.subdata(in: 4..<6).to(Int16.self))
        resist = Int(data.subdata(in: 6..<8).to(Int16.self))
        if data.count == 10 {
            runtime = -1
        } else {
            runtime = Int(data[8])
        }
        temperature = Int(data.subdata(in: 9..<10).to(Int8.self))
    }
}

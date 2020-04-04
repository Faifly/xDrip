//
//  DexcomG6TransmitterTimeRxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6TransmitterTimeRxMessage {
    let age: TimeInterval
    
    init(data: Data) throws {
        guard data.count >= 3 else { throw DexcomG6Error.invalidTransmitterTimeRx }
        guard data[0] == DexcomG6OpCode.transmitterTimeRx.rawValue else {
            throw DexcomG6Error.invalidTransmitterTimeRx
        }
        
        age = TimeInterval(data.subdata(in: 2..<6).to(Int32.self))
    }
}

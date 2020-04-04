//
//  DexcomG6TransmitterVersionRxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 01.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6TransmitterVersionRxMessage {
    let status: UInt8
    let firmwareVersion: Data

    init(data: Data) throws {
        guard data.count == 19 else { throw DexcomG6Error.invalidTransmitterVersionRx }
        guard data[0] == DexcomG6OpCode.transmitterVersionRx.rawValue else { throw DexcomG6Error.invalidTransmitterVersionRx }
        
        status = data[1]
        firmwareVersion = data[2..<6]
    }
}

//
//  DexcomG6TransmitterVersionTxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 31.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6TransmitterVersionTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    init() {
        data = Data([DexcomG6OpCode.transmitterVersionTx.rawValue]).appendingCRC()
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
}

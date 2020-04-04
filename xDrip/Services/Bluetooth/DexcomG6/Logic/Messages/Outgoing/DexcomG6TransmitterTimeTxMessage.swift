//
//  DexcomG6TransmitterTimeTxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6TransmitterTimeTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
    
    init() {
        data = Data([DexcomG6OpCode.transmitterTimeTx.rawValue]).appendingCRC()
    }
}

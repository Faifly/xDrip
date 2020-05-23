//
//  DexcomG6ResetTxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 22.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6ResetTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    init() {
        data = Data([DexcomG6OpCode.resetTx.rawValue]).appendingCRC()
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
}

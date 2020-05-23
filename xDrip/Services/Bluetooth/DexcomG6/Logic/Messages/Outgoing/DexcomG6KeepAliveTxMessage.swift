//
//  DexcomG6KeepAliveTxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6KeepAliveTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    init(seconds: UInt8) {
        data = Data([DexcomG6OpCode.keepAliveTx.rawValue, seconds])
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .notify
    }
}

//
//  DexcomG6GlucoseTxMessage.swift
//  xDrip
//
//  Created by Ivan Skoryk on 19.10.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6GlucoseTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    init() {
        data = Data([DexcomG6OpCode.glucoseTx.rawValue]).appendingCRC()
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
}

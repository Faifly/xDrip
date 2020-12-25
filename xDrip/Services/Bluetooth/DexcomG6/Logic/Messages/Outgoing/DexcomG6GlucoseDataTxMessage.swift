//
//  DexcomG6GlucoseDataTxMessage.swift
//  xDrip
//
//  Created by Dmitry on 25.12.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6GlucoseDataTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    init() {
        data = Data([DexcomG6OpCode.glucoseTx.rawValue]).appendingCRC()
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
}

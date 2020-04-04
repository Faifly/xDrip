//
//  DexcomG6PairRequestTxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 31.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6PairRequestTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    init() {
        data = Data([DexcomG6OpCode.pairRequestTx.rawValue])
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .notify
    }
}

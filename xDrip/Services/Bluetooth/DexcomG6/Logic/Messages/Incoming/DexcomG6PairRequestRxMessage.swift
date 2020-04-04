//
//  DexcomG6PairRequestRxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 31.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6PairRequestRxMessage {
    let paired: Bool
    
    init(data: Data) throws {
        guard data.count >= 2 else { throw DexcomG6Error.invalidPairRequestRx }
        guard data[0] == DexcomG6OpCode.pairRequestRx.rawValue else { throw DexcomG6Error.invalidPairRequestRx }
        paired = data[1] == 2
    }
}

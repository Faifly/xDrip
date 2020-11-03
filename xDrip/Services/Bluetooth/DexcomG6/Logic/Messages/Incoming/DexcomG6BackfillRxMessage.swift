//
//  DexcomG6BackfillRxMessage.swift
//  xDrip
//
//  Created by Ivan Skoryk on 02.11.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6BackfillRxMessage {
    let valid: Bool
    
    init(data: Data) throws {
        guard data.count >= 2 else { throw DexcomG6Error.invalidPairRequestRx }
        guard data[0] == DexcomG6OpCode.glucoseBackfillRx.rawValue else { throw DexcomG6Error.invalidPairRequestRx }
        valid = data[1] == 1
    }
}

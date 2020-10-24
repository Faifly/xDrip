//
//  DexcomG6BackfillTxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 24.10.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6BackfillTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    init(startTime: Int, endTime: Int) {
        var data = Data([DexcomG6OpCode.glucoseBackfillTx.rawValue, 0x5, 0x2, 0x0])
        
        withUnsafeBytes(of: startTime) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: endTime) { data.append(contentsOf: $0) }
        data.append(contentsOf: [UInt8](repeating: 0, count: 6))
        
        self.data = data.appendingCRC()
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
}

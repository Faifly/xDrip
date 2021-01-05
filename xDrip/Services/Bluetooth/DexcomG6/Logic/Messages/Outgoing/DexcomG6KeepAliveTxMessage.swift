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
        var dataArray = [Int8]()
        dataArray.append(Int8(DexcomG6OpCode.keepAliveTx.rawValue))
        dataArray.append(Int8(bitPattern: seconds))
        data = dataArray.withUnsafeBufferPointer { Data(buffer: $0) }
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .notify
    }
}

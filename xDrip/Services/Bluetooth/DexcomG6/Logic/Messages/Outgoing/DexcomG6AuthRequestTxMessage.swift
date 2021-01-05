//
//  DexcomG6AuthRequestTxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6AuthRequestTxMessage: DexcomG6OutgoingMessage {
    var data: Data {
        var dataArray = [Int8]()
        dataArray.append(Int8(DexcomG6OpCode.authRequestTx.rawValue))
        
        let uuid = UUID().uuid
        dataArray.append(Int8(bitPattern: uuid.0))
        dataArray.append(Int8(bitPattern: uuid.1))
        dataArray.append(Int8(bitPattern: uuid.2))
        dataArray.append(Int8(bitPattern: uuid.3))
        dataArray.append(Int8(bitPattern: uuid.4))
        dataArray.append(Int8(bitPattern: uuid.5))
        dataArray.append(Int8(bitPattern: uuid.6))
        dataArray.append(Int8(bitPattern: uuid.7))
        dataArray.append(0x2)

        return dataArray.withUnsafeBufferPointer { Data(buffer: $0) }
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .notify
    }
}

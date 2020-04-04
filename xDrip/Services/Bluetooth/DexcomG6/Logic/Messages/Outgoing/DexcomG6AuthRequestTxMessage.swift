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
        var data = Data()
        data.append(DexcomG6OpCode.authRequestTx.rawValue)
        
        let uuid = UUID().uuid
        data.append(uuid.0)
        data.append(uuid.1)
        data.append(uuid.2)
        data.append(uuid.3)
        data.append(uuid.4)
        data.append(uuid.5)
        data.append(uuid.6)
        data.append(uuid.7)
        data.append(0x2)
        
        return data
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .notify
    }
}

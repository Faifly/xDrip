//
//  DexcomG6AuthRequestRxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6AuthRequestRxMessage {
    let challenge: Data
    
    init(data: Data) throws {
        guard data.count >= 17 else { throw DexcomG6Error.invalidAuthRequestRx }
        guard data[0] == DexcomG6OpCode.authRequestRx.rawValue else { throw DexcomG6Error.invalidAuthRequestRx }
        challenge = data.subdata(in: 9..<17)
    }
}

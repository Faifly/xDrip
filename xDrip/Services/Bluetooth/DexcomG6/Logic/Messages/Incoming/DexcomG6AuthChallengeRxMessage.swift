//
//  DexcomG6AuthChallengeRxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6AuthChallengeRxMessage {
    let authenticated: Bool
    let paired: Bool
    
    init(data: Data) throws {
        guard data.count >= 3 else { throw DexcomG6Error.invalidAuthChallengeRx }
        authenticated = data[1] == 1
        paired = data[2] != 2
    }
}

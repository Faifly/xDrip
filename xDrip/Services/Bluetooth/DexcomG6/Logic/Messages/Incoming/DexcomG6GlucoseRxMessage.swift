//
//  DexcomG6GlucoseRxMessage.swift
//  xDrip
//
//  Created by Ivan Skoryk on 19.10.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6GlucoseRxMessage: DexcomG6BaseGlucoseMessageProtocol {
    let status: UInt8
    let filtered: Double
    let unfiltered: Double
    
    init(data: Data) throws {
        guard data.count >= 14 else { throw DexcomG6Error.invalidSensorDataRx }
        guard data[0] == DexcomG6OpCode.glucoseRx.rawValue else { throw DexcomG6Error.invalidSensorDataRx }

        status = data[1]
        
        let glucose = Data(data[10..<12]).to(UInt16.self) & 0xfff
        
        if glucose > 13 {
            filtered = Double(glucose * 1000)
            unfiltered = Double(glucose * 1000)
        } else {
            filtered = Double(glucose)
            unfiltered = Double(glucose)
        }
    }
}

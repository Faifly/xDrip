//
//  DexcomG6SessionStartTxMessage.swift
//  xDrip
//
//  Created by Dmitry on 08.01.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation

struct DexcomG6SessionStopTxMessage: DexcomG6OutgoingMessage {
    let data: Data

        init(stopTime: Int) {
            var array = [Int8]()

            array.append(Int8(DexcomG6OpCode.sessionStopTx.rawValue))

            withUnsafeBytes(of: stopTime) {
                array.append(contentsOf: Array($0.prefix(4 * MemoryLayout<Int8>.size)).map { Int8(bitPattern: $0) })
            }
            
            let data = array.withUnsafeBufferPointer { Data(buffer: $0) }

            self.data = data.appendingCRC()
            
            LogController.log(
                message: "[Dexcom G6] DexcomG6SessionStopTxMessage array: %@",
                type: .debug,
                array.description
            )
        }

    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
}

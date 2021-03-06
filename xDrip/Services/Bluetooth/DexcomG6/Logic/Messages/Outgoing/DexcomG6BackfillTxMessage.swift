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
            var array = [Int8]()

            array.append(contentsOf: [Int8(DexcomG6OpCode.glucoseBackfillTx.rawValue), 0x5, 0x2, 0x0])

            withUnsafeBytes(of: startTime) {
                array.append(contentsOf: Array($0.prefix(4 * MemoryLayout<Int8>.size)).map { Int8(bitPattern: $0) })
            }
            
            withUnsafeBytes(of: endTime) {
                array.append(contentsOf: Array($0.prefix(4 * MemoryLayout<Int8>.size)).map { Int8(bitPattern: $0) })
            }

            array.append(contentsOf: [Int8](repeating: 0, count: 6))

            let data = array.withUnsafeBufferPointer { Data(buffer: $0) }

            self.data = data.appendingCRC()
        }

    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
}

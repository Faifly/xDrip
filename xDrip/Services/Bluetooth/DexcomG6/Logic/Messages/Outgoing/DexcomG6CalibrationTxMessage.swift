//
//  DexcomG6CalibrationTxMessage.swift
//  xDrip
//
//  Created by Dmitry on 29.12.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation


struct DexcomG6CalibrationTxMessage: DexcomG6OutgoingMessage {
    let data: Data

        init(glucose: Int, time: Int) {
            var array = [Int8]()

            array.append(Int8(DexcomG6OpCode.calibrateGlucoseTx.rawValue))

            withUnsafeBytes(of: glucose) {
                array.append(contentsOf: Array($0.prefix(2 * MemoryLayout<Int8>.size)).map { Int8(bitPattern: $0) })
            }
            
            withUnsafeBytes(of: time) {
                array.append(contentsOf: Array($0.prefix(4 * MemoryLayout<Int8>.size)).map { Int8(bitPattern: $0) })
            }

            let data = array.withUnsafeBufferPointer { Data(buffer: $0) }

            self.data = data.appendingCRC()
        }

    var characteristic: DexcomG6CharacteristicType {
        return .write
    }
}

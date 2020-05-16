//
//  Data+Hex.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension Data {
    private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)
    
    var hexEncodedString: String {
        return String(
            reduce(
                into: "".unicodeScalars, { result, value in
                    result.append(Data.hexAlphabet[Int(value / 16)])
                    result.append(Data.hexAlphabet[Int(value % 16)])
                }
            )
        )
    }
    
    func appendingCRC() -> Data {
        var data = self
        let crc = crc16
        data.append(UInt8(crc & 0x00ff))
        data.append(UInt8(crc >> 8))
        return data
    }
    
    func to<T: FixedWidthInteger>(_: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}

fileprivate extension Collection where Element == UInt8 {
    private var crcCCITTXModem: UInt16 {
        var crc: UInt16 = 0

        for byte in self {
            crc ^= UInt16(byte) << 8

            for _ in 0..<8 {
                if crc & 0x8000 != 0 {
                    crc = crc << 1 ^ 0x1021
                } else {
                    crc = crc << 1
                }
            }
        }

        return crc
    }

    var crc16: UInt16 {
        return crcCCITTXModem
    }
}

fileprivate extension UInt8 {
    var crc16: UInt16 {
        return [self].crc16
    }
}

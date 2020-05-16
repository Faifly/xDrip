//
//  DexcomG6AuthChallengeTxMessage.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import CommonCrypto

// swiftlint:disable closure_body_length

struct DexcomG6AuthChallengeTxMessage: DexcomG6OutgoingMessage {
    let data: Data
    
    init(challenge: Data, serial: String) throws {
        guard serial.count == 6 else { throw DexcomG6Error.invalidSerial }
        
        var doubleData = Data(capacity: challenge.count * 2)
        doubleData.append(challenge)
        doubleData.append(challenge)
        
        guard let cryptKey = "00\(serial)00\(serial)".data(using: .utf8) else { throw DexcomG6Error.invalidSerial }
        guard let encrypted = doubleData.aes128Encrypt(keyData: cryptKey) else { throw DexcomG6Error.invalidSerial }
        
        var challengeResponse = Data()
        challengeResponse.append(DexcomG6OpCode.authChallengeTx.rawValue)
        challengeResponse.append(contentsOf: encrypted[0..<8])
        
        self.data = challengeResponse
    }
    
    var characteristic: DexcomG6CharacteristicType {
        return .notify
    }
}

private extension Data {
    func aes128Encrypt(keyData: Data) -> Data? {
        guard keyData.count == kCCKeySizeAES128 else { return nil }
        
        let cryptLength = size_t(count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)
        
        var numBytesEncrypted: size_t = 0
        let options = CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode)
        
        let cryptStatus: CCCryptorStatus = cryptData.withUnsafeMutableBytes {
            guard let cryptBytes = $0.baseAddress else {
                return CCCryptorStatus(kCCMemoryFailure)
            }
            let cryptStatus: CCCryptorStatus = self.withUnsafeBytes {
                guard let dataBytes = $0.baseAddress else {
                    return CCCryptorStatus(kCCMemoryFailure)
                }
                return keyData.withUnsafeBytes {
                    guard let keyBytes = $0.baseAddress else {
                        return CCCryptorStatus(kCCMemoryFailure)
                    }
                    return CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        options,
                        keyBytes,
                        kCCKeySizeAES128,
                        nil,
                        dataBytes,
                        self.count,
                        cryptBytes,
                        cryptLength,
                        &numBytesEncrypted
                    )
                }
            }
            return cryptStatus
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.count = numBytesEncrypted
        } else {
            return nil
        }
        return cryptData
    }
}

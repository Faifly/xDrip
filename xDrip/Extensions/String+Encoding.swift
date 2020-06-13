//
//  String+Encoding.swift
//  xDrip
//
//  Created by Artem Kalmykov on 12.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    var sha1: String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

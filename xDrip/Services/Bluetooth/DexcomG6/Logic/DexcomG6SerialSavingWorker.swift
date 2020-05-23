//
//  DexcomG6SerialSavingWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class DexcomG6SerialSavingWorker {
    private let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
    
    func validate(_ identifier: String?) -> Bool {
        guard let identifier = identifier else { return false }
        guard identifier.count == 6 else { return false }
        guard identifier.satisfies(characterSet: allowedCharacters) else { return false }
        return true
    }
    
    func saveID(_ identifier: String?) {
        CGMDevice.current.updateMetadata(ofType: .serialNumber, value: identifier)
    }
}

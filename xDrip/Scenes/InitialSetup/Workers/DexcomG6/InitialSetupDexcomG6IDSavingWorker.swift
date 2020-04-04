//
//  InitialSetupDexcomG6IDSavingWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class InitialSetupDexcomG6IDSavingWorker {
    private let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
    
    func validate(_ id: String?) -> Bool {
        guard let id = id else { return false }
        guard id.count == 6 else { return false }
        guard id.satisfies(characterSet: allowedCharacters) else { return false }
        return true
    }
    
    func saveID(_ id: String?) {
        CGMDevice.current.updateMetadata(ofType: .serialNumber, value: id)
    }
}

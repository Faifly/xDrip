//
//  String+Validation.swift
//  xDrip
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension String {
    func satisfies(characterSet: CharacterSet) -> Bool {
        for char in self {
            for scalarValue in char.unicodeScalars {
                let scalar = Unicode.Scalar(scalarValue)
                if !characterSet.contains(scalar) {
                    return false
                }
            }
        }
        
        return true
    }
}

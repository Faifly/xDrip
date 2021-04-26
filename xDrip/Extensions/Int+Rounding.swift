//
//  Int+Rounding.swift
//  xDrip
//
//  Created by Dmitry on 26.04.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation

extension Int {
    var roundedUp: Int {
        if self.isMultiple(of: 10) {
            return self
        }
        return (10 - self % 10) + self
    }
    
    var roundedDown: Int {
        return self - self % 10
    }
}

//
//  Double+Rounding.swift
//  xDrip
//
//  Created by Artem Kalmykov on 16.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension Double {
    func rounded(to decimals: Int) -> Double {
        let multiplier = pow(10.0, Double(decimals))
        return Double((multiplier * self).rounded() / multiplier)
    }
}

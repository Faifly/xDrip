//  Double+Round.swift
//  xDrip
//
//  Created by Dmitry on 6/17/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

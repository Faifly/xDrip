//
//  SlopeParameters.swift
//  xDrip
//
//  Created by Artem Kalmykov on 01.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct SlopeParameters {
    static let highestSaneIntercept = 39.0
    
    let lowSlope1: Double
    let lowSlope2: Double
    let highSlope1: Double
    let highSlope2: Double
    let defaultLowSlopeLow: Double
    let defaultLowSlopeHigh: Double
    let defaultSlope: Double
    let defaultHighSlopeHigh: Double
    let defaultHighSlopeLow: Double
    
    static let dex = SlopeParameters(
        lowSlope1: 0.75,
        lowSlope2: 0.70,
        highSlope1: 1.5,
        highSlope2: 1.6,
        defaultLowSlopeLow: 0.75,
        defaultLowSlopeHigh: 0.70,
        defaultSlope: 1.0,
        defaultHighSlopeHigh: 1.5,
        defaultHighSlopeLow: 1.5
    )
}

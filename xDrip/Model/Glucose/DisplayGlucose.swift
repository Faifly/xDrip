//
//  DisplayGlucose.swift
//  xDrip
//
//  Created by Artem Kalmykov on 27.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct DisplayGlucose {
    let mgDl: Double
    let deltaMgDl: Double
    var slope: Double = 0.0
    var deltaName: String = ""
    
    init?(readings: [GlucoseReading]) {
        guard let last = readings.last else { return nil }

        mgDl = last.calculatedValue
        let timestamp = last.date?.timeIntervalSince1970 ?? 0.0

        let previousEstimate: Double
        let previousTimestamp: Double

        if readings.count > 1 {
            previousEstimate = readings[0].calculatedValue
            previousTimestamp = readings[0].date?.timeIntervalSince1970 ?? 0.0
        } else {
            previousEstimate = 0.0
            previousTimestamp = 0.0
        }
        
        deltaMgDl = mgDl - previousEstimate
        
        if timestamp ~~ previousTimestamp || mgDl ~ previousEstimate {
            slope = 0.0
        } else {
            slope = (previousEstimate - mgDl) / (previousTimestamp - timestamp)
        }
        
        deltaName = DisplayGlucose.slopeName(slope * .secondsPerMinute)
    }
    
    static func slopeName(_ slope: Double) -> String {
        if slope <= -3.5 {
            return "DoubleDown"
        } else if slope <= -2.0 {
            return "SingleDown"
        } else if slope <= -1.0 {
            return "FortyFiveDown"
        } else if slope <= 1.0 {
            return "Flat"
        } else if slope <= 2.0 {
            return "FortyFiveUp"
        } else if slope <= 3.5 {
            return "SingleUp"
        } else if slope <= 40.0 {
            return "DoubleUp"
        }
        
        return "NONE"
    }
}

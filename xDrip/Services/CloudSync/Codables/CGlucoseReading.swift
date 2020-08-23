//
//  CGlucoseReading.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct CGlucoseReading: Codable {
    let device: String?
    let identifier: String?
    let type: String?
    let date: Int64?
    let sgv: Double?
    let filtered: Double?
    let unfiltered: Double?
    let slope: Double?
    let direction: String?
    let rssi: Double?
    let noise: String?
    
    init(reading: GlucoseReading) {
        identifier = reading.externalID
        type = "sgv"
        date = Int64((reading.date?.timeIntervalSince1970 ?? 0.0) * 1000.0)
        if User.current.settings.nightscoutSync?.sendDisplayGlucose == true {
            sgv = reading.displayGlucose.rounded(to: 2)
            slope = reading.displaySlope * 5.0 * .secondsPerMinute
            direction = reading.displayDeltaName
        } else {
            sgv = reading.calculatedValue.rounded(to: 2)
            slope = reading.activeSlope() * 5.0 * .secondsPerMinute
            direction = nil
        }
        filtered = reading.rawValue.rounded(to: 2)
        unfiltered = reading.filteredValue.rounded(to: 2)
        rssi = reading.rssi
        noise = reading.noise
        
        var deviceString = "xDrip iOS"
        if User.current.settings.nightscoutSync?.appendSourceInfoToDevices == true,
            let info = reading.sourceInfo, !info.isEmpty {
            deviceString += " " + info
        }
        
        device = deviceString
    }
}

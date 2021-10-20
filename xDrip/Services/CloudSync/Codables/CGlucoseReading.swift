//
//  CGlucoseReading.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length

struct CGlucoseReading: Codable {
    let id: String?
    let device: String?
    let identifier: String?
    let type: String?
    let date: Double?
    let sgv: Double?
    let filtered: Double?
    let unfiltered: Double?
    let slope: Double?
    let direction: String?
    let rssi: Double?
    let noise: String?
    
    enum CodingKeys: String, CodingKey {
        case device
        case identifier
        case id = "_id"
        case type
        case date
        case sgv
        case filtered
        case unfiltered
        case slope
        case direction
        case rssi
        case noise
    }
    
    init(reading: GlucoseReading) {
        id = nil
        identifier = reading.externalID
        type = "sgv"
        date = Double((reading.date?.timeIntervalSince1970 ?? 0.0) * 1000.0)
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
        
        var deviceString = Constants.Nightscout.appIdentifierName
        if User.current.settings.nightscoutSync?.appendSourceInfoToDevices == true,
            let info = reading.sourceInfo, !info.isEmpty {
            deviceString += " " + info
        }
        
        device = deviceString
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        device = try? container.decode(String.self, forKey: .device)
        id = try? container.decode(String.self, forKey: .id)
        
        if let identifier = try? container.decode(String.self, forKey: .identifier) {
            self.identifier = identifier
        } else if let identifier = try? container.decode(String.self, forKey: .id) {
            self.identifier = identifier
        } else {
            identifier = UUID().uuidString
        }
        
        type = try? container.decode(String.self, forKey: .type)
        date = try? container.decode(Double.self, forKey: .date)

        if let sgv = try? container.decode(Double.self, forKey: .sgv) {
            self.sgv = sgv
        } else if let sgv = try? container.decode(Int.self, forKey: .sgv) {
            self.sgv = Double(sgv)
        } else {
            sgv = nil
        }

        if let filtered = try? container.decode(Double.self, forKey: .filtered) {
            self.filtered = filtered
        } else if let filtered = try? container.decode(Int.self, forKey: .filtered) {
            self.filtered = Double(filtered)
        } else {
            filtered = nil
        }

        if let unfiltered = try? container.decode(Double.self, forKey: .unfiltered) {
            self.unfiltered = unfiltered
        } else if let unfiltered = try? container.decode(Int.self, forKey: .unfiltered) {
            self.unfiltered = Double(unfiltered)
        } else {
            unfiltered = nil
        }

        slope = try? container.decode(Double.self, forKey: .slope)
        direction = try? container.decode(String.self, forKey: .direction)

        if let rssi = try? container.decode(Double.self, forKey: .rssi) {
            self.rssi = rssi
        } else if let rssi = try? container.decode(Int.self, forKey: .rssi) {
            self.rssi = Double(rssi)
        } else {
            rssi = nil
        }

        if let noise = try? container.decode(String.self, forKey: .noise) {
            self.noise = noise
        } else if let noise = try? container.decode(Int.self, forKey: .noise) {
            self.noise = "\(noise)"
        } else {
            noise = nil
        }
    }
}

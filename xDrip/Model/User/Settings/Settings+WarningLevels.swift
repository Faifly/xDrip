//
//  Settings+WarningLevels.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension Settings {
    /// Returns nil if normal
    func warningLevel(forValue value: Double) -> GlucoseWarningLevel? {
        if value <= warningLevelValue(for: .urgentLow) {
            return .urgentLow
        } else if value <= warningLevelValue(for: .low) {
            return .low
        } else if value >= warningLevelValue(for: .urgentHigh) {
            return .urgentHigh
        } else if value >= warningLevelValue(for: .high) {
            return .high
        }
        return nil
    }
}

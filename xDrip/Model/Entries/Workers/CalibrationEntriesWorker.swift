//
//  CalibrationEntriesWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 21.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class CalibrationEntriesWorker: AbstractEntriesWorker {
    @discardableResult static func addCalibrationEntry(
        firstValue: Double,
        secondValue: Double,
        date: Date) -> CalibrationEntry {
        let entry = CalibrationEntry(firstValue: firstValue, secondValue: secondValue, date: date)
        return add(entry: entry)
    }
    
    static func fetchAllEntries(mode: UserDeviceMode? = nil) -> [CalibrationEntry] {
        let entries = super.fetchAllEntries(type: CalibrationEntry.self)
            .filter(.deviceMode(mode: mode ?? User.current.settings.deviceMode))
        return Array(entries)
    }
}

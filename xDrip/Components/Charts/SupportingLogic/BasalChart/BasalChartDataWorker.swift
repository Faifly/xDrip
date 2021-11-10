//
//  BasalChartDataWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 22.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AKUtils

enum BasalChartDataWorker {
    static func fetchAllBasalDataForCurrentMode() -> [InsulinEntry] {
        let result: [InsulinEntry]
        if User.current.settings.injectionType == .pen {
            result = InsulinEntriesWorker.fetchAllBasalEntries()
        } else if User.current.settings.injectionType == .pump {
            result = InsulinEntriesWorker.fetchAllPumpBasalEntries()
        } else {
            result = []
        }
        return  result .filter { $0.isValid }
    }
}

//
//  DateInterval+Helpers.swift
//  xDrip
//
//  Created by Artem Kalmykov on 16.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension DateInterval {
    init(endDate: Date, duration: TimeInterval) {
        let startDate = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 - duration)
        self.init(start: startDate, end: endDate)
    }
}

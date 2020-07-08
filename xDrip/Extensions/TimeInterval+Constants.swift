//
//  TimeInterval+Constants.swift
//  xDrip
//
//  Created by Artem Kalmykov on 16.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension TimeInterval {
    static let secondsPerMinute: TimeInterval = 60.0
    static let secondsPerHour: TimeInterval = 3600.0
    static let secondsPerDay: TimeInterval = 86400.0
    
    static func minutes(_ minutes: Double) -> TimeInterval {
        return self.init(minutes: minutes)
    }

    static func hours(_ hours: Double) -> TimeInterval {
        return self.init(hours: hours)
    }

    init(minutes: Double) {
        self.init(minutes * .secondsPerMinute)
    }

    init(hours: Double) {
        self.init(minutes: hours * .secondsPerMinute)
    }

    var minutes: Double {
        return self / .secondsPerMinute
    }

    var hours: Double {
        return minutes / .secondsPerMinute
    }
}

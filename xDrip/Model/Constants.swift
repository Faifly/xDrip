//
//  Constants.swift
//  xDrip
//
//  Created by Ivan Skoryk on 28.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum Constants {
    static let tableViewReloadAnimationDuration = 0.25
    
    enum Glucose {
        static let defaultMissedReadingTimeInterval = 7 * TimeInterval.secondsPerMinute
        static let defaultPhoneMutedCheckTimeInterval = 4.0 * TimeInterval.secondsPerMinute + 45.0
        static let requiredReadingsCountToCalculateInterval = 4
    }
    
    enum Notifications {
        static let maximumRepeatCount = 9
    }
    
    enum Nightscout {
        static let appIdentifierName = "xDrip iOS"
    }
    
    static let specialG5RawValuePlaceholder = -0.1597
    static let maxBackfillPeriod = TimeInterval(hours: 3)
    static let dexcomPeriod = TimeInterval(minutes: 5)
    static let observablePeriod = .secondsPerDay * 90.0
}

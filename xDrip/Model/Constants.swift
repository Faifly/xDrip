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
        static let defaultMissedReadingTimeInterval = 5.0 * TimeInterval.secondsPerMinute
        static let defaultPhoneMutedCheckTimeInterval = 4.0 * TimeInterval.secondsPerMinute + 45.0
        static let requiredReadingsCountToCalculateInterval = 4
    }
    
    enum Notifications {
        static let maximumRepeatCount = 9
    }
}

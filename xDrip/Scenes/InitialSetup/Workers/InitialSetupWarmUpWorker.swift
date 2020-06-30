//
//  InitialSetupWarmUpWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 27.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class InitialSetupWarmUpWorker {
    func timeUntilWarmUpFinished() -> String? {
        guard let sensorStartString = CGMDevice.current.metadata(ofType: .sensorAge)?.value else { return nil }
        guard let sensorStartInterval = TimeInterval(sensorStartString) else { return nil }
        let diffFromNow = Date().timeIntervalSince1970 - sensorStartInterval
        guard diffFromNow < .secondsPerHour * 2.0 else { return nil }
        let diff = .secondsPerHour * 2.0 - diffFromNow
        if diff < .secondsPerHour {
            return String(format: "initial_warmup_minutes_left".localized, (diff / .secondsPerMinute).rounded())
        }
        
        return String(
            format: "initial_warmup_hour_minutes_left".localized,
            ((diff - .secondsPerHour) / .secondsPerMinute).rounded()
        )
    }
}

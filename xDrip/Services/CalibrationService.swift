//
//  CalibrationService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol CalibrationServiceInterface {
    func isReadyForCalibration() -> (Bool, CalibrationService.CalibrationError?)
}

final class CalibrationService: CalibrationServiceInterface {
    enum CalibrationError: Error {
        case noInitialReadings
        
        var localizedDescription: String {
            switch self {
            case .noInitialReadings: return "calibration_not_ready_error_no_initial_readings".localized
            }
        }
    }
    
    func isReadyForCalibration() -> (Bool, CalibrationError?) {
        let all = Calibration.allForCurrentSensor
        
        if all.count == 0 {
            let readings = GlucoseReading.allForCurrentSensor
            if readings.count < 2 {
                return (false, .noInitialReadings)
            }
        }
        
        return (true, nil)
    }
}

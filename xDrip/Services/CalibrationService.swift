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
    enum CalibrationError: LocalizedError {
        case noInitialReadings
        case warmingUp
        case sensorStopped
        
        var localizedDescription: String {
            switch self {
            case .noInitialReadings: return "calibration_not_ready_error_no_initial_readings".localized
            case .warmingUp: return "calibration_not_ready_error_warming_up".localized
            case .sensorStopped: return "calibration_not_ready_error_sensor_stopped".localized
            }
        }
    }
    
    func isReadyForCalibration() -> (Bool, CalibrationError?) {
        guard CGMDevice.current.sensorStartDate != nil else { return (false, .sensorStopped) }
        guard !CGMDevice.current.isWarmingUp else { return (false, .warmingUp) }
        
        let all = Calibration.allForCurrentSensor
        
        if all.isEmpty {
            let readings = GlucoseReading.allMasterForCurrentSensor(valid: false)
            if CGMDevice.current.withCalibrationResponse {
                if !readings.contains(where: { reading in reading.calibrationState != .warmingUp }) {
                    return (false, .noInitialReadings)
                }
            } else {
                if readings.count < 2 {
                    return (false, .noInitialReadings)
                }
            }
        }
        
        return (true, nil)
    }
}

//
//  RootCalibrationValidatorWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol RootCalibrationValidatorProtocol {
    var isAllowedToCalibrate: RootCalibrationValidatorWorker.Result { get }
}

final class RootCalibrationValidatorWorker: RootCalibrationValidatorProtocol {
    enum Result {
        case allowed
        case notAllowed(errorTitle: String, errorMessage: String)
    }
    
    private let calibrationService: CalibrationServiceInterface
    
    init() {
        calibrationService = CalibrationService()
    }
    
    var isAllowedToCalibrate: Result {
        let readyState = calibrationService.isReadyForCalibration()
        
        if readyState.0 {
            return .allowed
        }
        
        let message = readyState.1?.localizedDescription ?? "calibration_not_ready_error_general_message".localized
        return .notAllowed(
            errorTitle: "calibration_not_ready_error_title".localized,
            errorMessage: message
        )
    }
}

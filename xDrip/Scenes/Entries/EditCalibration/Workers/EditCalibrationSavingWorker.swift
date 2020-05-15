//
//  EditCalibrationSavingWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 15.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol EditCalibrationSavingWorkerLogic {
    func saveInput(entry1: String?, entry2: String?, date1: Date, date2: Date) throws
}

final class EditCalibrationSavingWorker: EditCalibrationSavingWorkerLogic {
    func saveInput(entry1: String?, entry2: String?, date1: Date, date2: Date) throws {
        // TODO: Add entry sanity check
        guard let entry1 = entry1 else { throw EditCalibration.ValidationError.noGlucose1Input }
        guard let value1 = Double(entry1) else { throw EditCalibration.ValidationError.noGlucose1Input }
        
        let requiresInitialCalibration = Calibration.allForCurrentSensor.count == 0
        do {
            if requiresInitialCalibration {
                guard let entry2 = entry2 else { throw EditCalibration.ValidationError.noGlucose2Input }
                guard let value2 = Double(entry2) else { throw EditCalibration.ValidationError.noGlucose2Input }
                
                try Calibration.createInitialCalibration(
                    glucoseLevel1: value1,
                    glucoseLevel2: value2,
                    date1: date1,
                    date2: date2
                )
                CGMController.shared.notifyGlucoseChange()
            } else {
                try Calibration.createRegularCalibration(glucoseLevel: value1, date: date1)
                CGMController.shared.notifyGlucoseChange()
            }
        } catch CalibrationError.noReadingsNearDate {
            throw EditCalibration.ValidationError.noReadingsNearCalibration
        } catch CalibrationError.notEnoughReadings {
            throw EditCalibration.ValidationError.noReadingsNearCalibration
        } catch CalibrationError.sensorNotStarted {
            throw EditCalibration.ValidationError.sensorNotStarted
        }
    }
}

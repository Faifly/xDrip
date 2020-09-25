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

// swiftlint:disable todo
final class EditCalibrationSavingWorker: EditCalibrationSavingWorkerLogic {
    func saveInput(entry1: String?, entry2: String?, date1: Date, date2: Date) throws {
        // TODO: Add entry sanity check
        guard let entry1 = entry1 else { throw EditCalibration.ValidationError.noGlucose1Input }
        guard var value1 = Double(entry1) else { throw EditCalibration.ValidationError.noGlucose1Input }
        value1 = GlucoseUnit.convertToDefault(value1)
        
        let requiresInitialCalibration = Calibration.allForCurrentSensor.isEmpty
        do {
            if requiresInitialCalibration {
                let entry2 = entry2 ?? entry1
                var value2 = Double(entry2) ?? value1
                value2 = GlucoseUnit.convertToDefault(value2)
                
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
            
            NotificationCenter.default.postSettingsChangeNotification(setting: .warmUp)
        } catch CalibrationError.noReadingsNearDate {
            throw EditCalibration.ValidationError.noReadingsNearCalibration
        } catch CalibrationError.notEnoughReadings {
            throw EditCalibration.ValidationError.noReadingsNearCalibration
        } catch CalibrationError.sensorNotStarted {
            throw EditCalibration.ValidationError.sensorNotStarted
        }
    }
}

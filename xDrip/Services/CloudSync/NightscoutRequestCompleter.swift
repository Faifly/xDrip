//
//  NightscoutRequestCompleter.swift
//  xDrip
//
//  Created by Dmitry on 11.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum NightscoutRequestCompleter {
    static func completeRequest(_ request: UploadRequest) {
        DispatchQueue.main.async {
            switch request.type {
            case .postGlucoseReading, .modifyGlucoseReading:
                GlucoseReading.markEntryAsUploaded(externalID: request.itemID)
                NightscoutService.shared.sendDeviceStatus()
            case .deleteGlucoseReading, .deleteCalibration:
                break
            case .postCalibration:
                Calibration.markCalibrationAsUploaded(itemID: request.itemID)
            case .postCarbs, .modifyCarbs:
                CarbEntriesWorker.markEntryAsUploaded(externalID: request.itemID)
            case .deleteCarbs:
                CarbEntriesWorker.deleteEntryWith(externalID: request.itemID)
                
            case .postBolus, .modifyBolus, .postBasal, .modifyBasal:
                InsulinEntriesWorker.markEntryAsUploaded(externalID: request.itemID)
            case .deleteBolus, .deleteBasal:
                InsulinEntriesWorker.deleteEntryWith(externalID: request.itemID)
                
            case .postTraining, .modifyTraining:
                TrainingEntriesWorker.markEntryAsUploaded(externalID: request.itemID)
            case .deleteTraining:
                TrainingEntriesWorker.deleteEntryWith(externalID: request.itemID)
            }
        }
    }
}

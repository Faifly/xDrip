//
//  NightscoutRequestCompleter.swift
//  xDrip
//
//  Created by Dmitry on 11.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

// swiftlint:disable closure_body_length

enum NightscoutRequestCompleter {
    static func completeRequest(_ request: UploadRequest) {
        DispatchQueue.main.async {
            for itemID in request.itemIDs {
                switch request.type {
                case .postGlucoseReading, .modifyGlucoseReading:
                    GlucoseReading.markEntryAsUploaded(externalID: itemID)
                case .deleteGlucoseReading, .deleteCalibration:
                    break
                case .postCalibration:
                    Calibration.markCalibrationAsUploaded(itemID: itemID)
                case .postCarbs, .modifyCarbs:
                    CarbEntriesWorker.markEntryAsUploaded(externalID: itemID)
                case .deleteCarbs:
                    CarbEntriesWorker.deleteEntryWith(externalID: itemID)
                case .postBolus, .modifyBolus, .postBasal, .modifyBasal:
                    InsulinEntriesWorker.markEntryAsUploaded(externalID: itemID)
                case .deleteBolus, .deleteBasal:
                    InsulinEntriesWorker.deleteEntryWith(externalID: itemID)
                    
                case .postTraining, .modifyTraining:
                    TrainingEntriesWorker.markEntryAsUploaded(externalID: itemID)
                case .deleteTraining:
                    TrainingEntriesWorker.deleteEntryWith(externalID: itemID)
                }
            }
            NightscoutService.shared.sendDeviceStatus()
        }
    }
}

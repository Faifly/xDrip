//
//  NightscoutCloudBackfillInteractor.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import AKUtils

protocol NightscoutCloudBackfillBusinessLogic {
    func doLoad(request: NightscoutCloudBackfill.Load.Request)
    func doSend(request: NightscoutCloudBackfill.Send.Request)
}

protocol NightscoutCloudBackfillDataStore: AnyObject {    
}

final class NightscoutCloudBackfillInteractor: NightscoutCloudBackfillBusinessLogic, NightscoutCloudBackfillDataStore {
    var presenter: NightscoutCloudBackfillPresentationLogic?
    var router: NightscoutCloudBackfillRoutingLogic?
    
    private var date = Date()
    
    // MARK: Do something
    
    func doLoad(request: NightscoutCloudBackfill.Load.Request) {
        let response = NightscoutCloudBackfill.Load.Response(dateChangedHandler: handleDateChanged(_:))
        presenter?.presentLoad(response: response)
    }
    
    func doSend(request: NightscoutCloudBackfill.Send.Request) {
        let allGlucoseReadings = GlucoseReading.allMaster.filter( NSCompoundPredicate(type: .and, subpredicates: [
            .laterThan(date: date),
            .calculatedValue,
            .rawValue
        ])).prefix(500000)
        
        if allGlucoseReadings.isEmpty {
            router?.presentPopUp(message: "settings_nightscout_cloud_backfill_no_glucose_readings_found".localized,
                                 success: false)
            return
        }
        
        for entry in allGlucoseReadings {
            entry.updateCloudUploadStatus(.notUploaded)
        }
        
        NightscoutService.shared.scanForNotUploadedEntries()
        
        let allCarbEntries = CarbEntriesWorker.fetchAllCarbEntries()
        let allBolusEntries = InsulinEntriesWorker.fetchAllBolusEntries()
        let allBasalEntries = InsulinEntriesWorker.fetchAllBasalEntries()
        let allTrainings = TrainingEntriesWorker.fetchAllTrainings()
    
        var allTreatments: [AbstractEntry] = allCarbEntries + allBolusEntries + allBasalEntries + allTrainings
        
        allTreatments = Array(allTreatments.filter({ $0.date >? date }).prefix(50000))
        
        for entry in allTreatments {
            entry.updateCloudUploadStatus(.notUploaded)
        }
        
        NightscoutService.shared.scanForNotUploadedTreatments()
        
        let message = String(format: "settings_nightscout_cloud_backfill_found_readings_and_treatments".localized,
                             allGlucoseReadings.count,
                             allTreatments.count)
        
        router?.presentPopUp(message: message, success: true)
    }
    
    private func handleDateChanged(_ date: Date) {
        self.date = date
    }
}

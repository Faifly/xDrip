//
//  SettingsTransmitterTestDataWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.08.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import RealmSwift

protocol SettingsTransmitterTestDataWorkerLogic {
    func generateTestData(configuration: SettingsTransmitter.TestBackfillConfiguration,
                          callback: @escaping (Int, Int) -> Void)
}

final class SettingsTransmitterTestDataWorker: SettingsTransmitterTestDataWorkerLogic {
    private let glucoseStepMin = 0.1
//    private let glucoseStepMax = 10.0
    
    func generateTestData(configuration: SettingsTransmitter.TestBackfillConfiguration,
                          callback: @escaping (Int, Int) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.startDataGeneration(configuration: configuration, callback: callback)
        }
    }
    
    private func startDataGeneration(configuration: SettingsTransmitter.TestBackfillConfiguration,
                                     callback: @escaping (Int, Int) -> Void) {
        Calibration.deleteAll()
        Realm.shared.safeWrite {
            Realm.shared.delete(GlucoseReading.allMaster)
        }
        
        let backfillInterval = TimeInterval(configuration.days) * .secondsPerDay
        let readingsInterval = TimeInterval(configuration.minutesBetweenReading) * .secondsPerMinute
        
        let now = Date()
        var currentOffset = now.timeIntervalSince1970 - backfillInterval
        
        let readingsAmount = Int(backfillInterval / readingsInterval)
        var currentGlucose = configuration.minGlucose
        var increment = 1.0
        
        CGMDevice.current.sensorStartDate = Date(timeIntervalSince1970: currentOffset - .secondsPerHour * 3.0)
        CGMDevice.current.updateSensorIsStarted(true)
        
        for index in 0..<readingsAmount {
            callback(index, readingsAmount)
            
            GlucoseReading.create(
                filtered: currentGlucose,
                unfiltered: currentGlucose,
                rssi: 100.0,
                date: Date(timeIntervalSince1970: currentOffset),
                requireCalibration: false
            )
            
            if index == 1 {
                try? Calibration.createInitialCalibration(
                    glucoseLevel1: currentGlucose,
                    glucoseLevel2: currentGlucose + 1.0,
                    date1: Date(timeIntervalSince1970: currentOffset),
                    date2: Date(timeIntervalSince1970: currentOffset)
                )
            }
            
            currentOffset += readingsInterval
            
            let step = Double.random(in: glucoseStepMin...configuration.maxStepDeviation)
            
            if configuration.isChaotic {
                if currentGlucose + configuration.maxStepDeviation > configuration.maxGlucose {
                    currentGlucose -= step
                } else if currentGlucose - configuration.maxStepDeviation < configuration.minGlucose {
                    currentGlucose += step
                } else {
                    if .random() {
                        currentGlucose += step
                    } else {
                        currentGlucose -= step
                    }
                }
            } else {
                currentGlucose += increment * step
                
                if currentGlucose >= configuration.maxGlucose && increment > 0 {
                    increment = -1.0
                } else if currentGlucose <= configuration.minGlucose && increment < 0 {
                    increment = 1.0
                }
            }
        }
    }
}

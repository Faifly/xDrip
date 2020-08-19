//
//  HomeGlucoseDataWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import AKUtils

protocol HomeGlucoseDataWorkerProtocol: AnyObject {
    var glucoseDataHandler: (() -> Void)? { get set }
    func fetchGlucoseData(for hours: Int) -> [GlucoseReading]
    func fetchGlucoseData(for date: Date) -> [GlucoseReading]
    func fetchLastGlucoseReading() -> GlucoseReading?
}

final class HomeGlucoseDataWorker: NSObject, HomeGlucoseDataWorkerProtocol {
    var glucoseDataHandler: (() -> Void)?
    
    override init() {
        super.init()
        CGMController.shared.subscribeForGlucoseDataEvents(listener: self) { [weak self] _ in
            guard let self = self else { return }
            self.glucoseDataHandler?()
        }
    }
    
    func fetchGlucoseData(for hours: Int) -> [GlucoseReading] {
        let minimumDate = Date() - TimeInterval(hours) * .secondsPerHour
        let all = User.current.settings.deviceMode == .main ? GlucoseReading.allMaster : GlucoseReading.allFollower
        return Array(
            all.filter { $0.date >=? minimumDate && $0.filteredCalculatedValue > .ulpOfOne }
        )
    }
    
    func fetchLastGlucoseReading() -> GlucoseReading? {
        let minimumDate = Date() - .secondsPerDay
        let lastReading = User.current.settings.deviceMode == .main ?
            GlucoseReading.allMaster.first : GlucoseReading.allFollower.first
        if let reading = lastReading, reading.date >=? minimumDate && reading.filteredCalculatedValue > .ulpOfOne {
            return reading
        } else {
            return nil
        }
    }
    
    func fetchGlucoseData(for date: Date) -> [GlucoseReading] {
        let minimumDate = Calendar.current.startOfDay(for: date)
        let maximumDate = minimumDate + .secondsPerDay
        
        let all = User.current.settings.deviceMode == .main ? GlucoseReading.allMaster : GlucoseReading.allFollower
        
        return Array(
            all.filter {
                $0.date >=? minimumDate &&
                $0.filteredCalculatedValue > .ulpOfOne &&
                $0.date <=? maximumDate
            }
        )
    }
}

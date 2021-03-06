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
import RealmSwift

protocol HomeGlucoseDataWorkerProtocol: AnyObject {
    var glucoseDataHandler: (() -> Void)? { get set }
    func fetchGlucoseData(for hours: Int, readings: Results<GlucoseReading>) -> [BaseGlucoseReading]
    func fetchGlucoseData(for date: Date, readings: Results<GlucoseReading>) -> [BaseGlucoseReading]
    func fetchGlucoseData(for dateInterval: DateInterval, readings: Results<GlucoseReading>) -> [BaseGlucoseReading]
    func fetchLastGlucoseReading(readings: Results<GlucoseReading>) -> BaseGlucoseReading?
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
    
    func fetchGlucoseData(for hours: Int, readings: Results<GlucoseReading>) -> [BaseGlucoseReading] {
        let dateInterval = DateInterval(
            endDate: Date(),
            duration: TimeInterval(hours: Double(hours))
        )
        return fetchGlucoseData(for: dateInterval, readings: readings)
    }
    
    func fetchLastGlucoseReading(readings: Results<GlucoseReading>) -> BaseGlucoseReading? {
        let minimumDate = Date() - .secondsPerDay
        if let reading = readings.first, reading.date >=? minimumDate && reading.filteredCalculatedValue > .ulpOfOne {
            return reading
        } else {
            return nil
        }
    }
    
    func fetchGlucoseData(for date: Date, readings: Results<GlucoseReading>) -> [BaseGlucoseReading] {
        let minimumDate = Calendar.current.startOfDay(for: date)
        let maximumDate = minimumDate + .secondsPerDay
        
        let dateInterval = DateInterval(endDate: maximumDate, duration: .secondsPerDay)
        return fetchGlucoseData(for: dateInterval, readings: readings)
    }
    
    func fetchGlucoseData(for dateInterval: DateInterval, readings: Results<GlucoseReading>) -> [BaseGlucoseReading] {
        let minimumDate = dateInterval.start
        let maximumDate = dateInterval.end
        let filtered = readings.filter(
            NSCompoundPredicate(type: .and, subpredicates: [
                                    .laterThanOrEqual(date: minimumDate),
                                    .earlierThanOrEqual(date: maximumDate),
                                    .filteredCalculatedValue
            ]))
        
        return Array(filtered)
    }
}

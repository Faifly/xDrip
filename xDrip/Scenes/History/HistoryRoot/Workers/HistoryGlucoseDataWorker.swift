//
//  HistoryGlucoseDataWorker.swift
//  xDrip
//
//  Created by Dmitry on 23.02.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import UIKit
import AKUtils
import RealmSwift

protocol HistoryGlucoseDataWorkerProtocol: AnyObject {
    var glucoseDataHandler: (() -> Void)? { get set }
    func fetchGlucoseData(for hours: Int, readings: Results<LightGlucoseReading>) -> [BaseGlucoseReading]
    func fetchGlucoseData(for date: Date, readings: Results<LightGlucoseReading>) -> [BaseGlucoseReading]
    func fetchGlucoseData(for dateInterval: DateInterval, readings: Results<LightGlucoseReading>) -> [BaseGlucoseReading]
    func fetchLastGlucoseReading(readings: Results<LightGlucoseReading>) -> BaseGlucoseReading?
}

final class HistoryGlucoseDataWorker: NSObject, HistoryGlucoseDataWorkerProtocol {
    var glucoseDataHandler: (() -> Void)?
    
    override init() {
        super.init()
        CGMController.shared.subscribeForGlucoseDataEvents(listener: self) { [weak self] _ in
            guard let self = self else { return }
            self.glucoseDataHandler?()
        }
    }
    
    func fetchGlucoseData(for hours: Int, readings: Results<LightGlucoseReading>) -> [BaseGlucoseReading] {
        let dateInterval = DateInterval(
            endDate: Date(),
            duration: TimeInterval(hours: Double(hours))
        )
        return fetchGlucoseData(for: dateInterval, readings: readings)
    }
    
    func fetchLastGlucoseReading(readings: Results<LightGlucoseReading>) -> BaseGlucoseReading? {
        let minimumDate = Date() - .secondsPerDay
        if let reading = readings.first, reading.date >=? minimumDate && reading.filteredCalculatedValue > .ulpOfOne {
            return reading
        } else {
            return nil
        }
    }
    
    func fetchGlucoseData(for date: Date, readings: Results<LightGlucoseReading>) -> [BaseGlucoseReading] {
        let minimumDate = Calendar.current.startOfDay(for: date)
        let maximumDate = minimumDate + .secondsPerDay
        
        let dateInterval = DateInterval(endDate: maximumDate, duration: .secondsPerDay)
        return fetchGlucoseData(for: dateInterval, readings: readings)
    }
    
    func fetchGlucoseData(for dateInterval: DateInterval, readings: Results<LightGlucoseReading>)
    -> [BaseGlucoseReading] {
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

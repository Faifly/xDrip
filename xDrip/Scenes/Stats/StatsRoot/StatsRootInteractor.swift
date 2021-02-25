//
//  StatsRootInteractor.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import RealmSwift

protocol StatsRootBusinessLogic {
    func doLoad(request: StatsRoot.Load.Request)
    func doCancel(request: StatsRoot.Cancel.Request)
    func doSelectTimeFrame(request: StatsRoot.UpdateTimeFrame.Request)
}

protocol StatsRootDataStore: AnyObject {    
}

final class StatsRootInteractor: StatsRootBusinessLogic, StatsRootDataStore {
    var presenter: StatsRootPresentationLogic?
    var router: StatsRootRoutingLogic?
    
    private var timeFrame: StatsRoot.TimeFrame = .today
    
    // MARK: Do something
    
    func doLoad(request: StatsRoot.Load.Request) {
        let response = StatsRoot.Load.Response()
        presenter?.presentLoad(response: response)
        updateData()
    }
    
    func doCancel(request: StatsRoot.Cancel.Request) {
        router?.dismissSelf()
    }
    
    func doSelectTimeFrame(request: StatsRoot.UpdateTimeFrame.Request) {
        timeFrame = request.timeFrame
        updateData()
    }
    
    // MARK: Logic
    
    private func updateData() {
        let startDate: Date
        let interval: TimeInterval
        
        switch timeFrame {
        case .today:
            startDate = Calendar.current.startOfDay(for: Date())
            interval = .secondsPerDay
            
        case .yesterday:
            startDate = Calendar.current.startOfDay(for: Date() - .secondsPerDay)
            interval = .secondsPerDay
            
        case .sevenDays:
            startDate = Calendar.current.startOfDay(for: Date() - .secondsPerDay * 6.0)
            interval = .secondsPerDay * 7.0
            
        case .thirtyDays:
            startDate = Calendar.current.startOfDay(for: Date() - .secondsPerDay * 29.0)
            interval = .secondsPerDay * 30.0
            
        case .nintyDays:
            startDate = Calendar.current.startOfDay(for: Date() - .secondsPerDay * 89.0)
            interval = .secondsPerDay * 90.0
        }
        
        let dateInterval = DateInterval(start: startDate, duration: interval)
        
        let grossReadingsResults = GlucoseReading.readingsForInterval(dateInterval)
            .filter(.filteredCalculatedValue)
        let lightReadingsResults = LightGlucoseReading.readingsForInterval(dateInterval)
            .filter(.filteredCalculatedValue)
        
        let grossReadings: [BaseGlucoseReading] = Array(grossReadingsResults)
        let lightReadings: [BaseGlucoseReading] = Array(lightReadingsResults)
        
        let readings = grossReadings + lightReadings
    
        updateTableData(readings: readings)
        updateChartData(readings: readings, interval: dateInterval)
    }
    
    private func updateTableData(readings: [BaseGlucoseReading]) {
        let response = StatsRoot.UpdateTableData.Response(
            readings: readings,
            lowGlucoseThreshold: User.current.settings.warningLevelValue(for: .low),
            highGlucoseThreshold: User.current.settings.warningLevelValue(for: .high),
            unit: User.current.settings.unit
        )
        presenter?.presentTableData(response: response)
    }
    
    private func updateChartData(readings: [BaseGlucoseReading], interval: DateInterval) {
        let response = StatsRoot.UpdateChartData.Response(readings: readings, timeFrame: timeFrame, interval: interval)
        presenter?.presentChartData(response: response)
    }
}

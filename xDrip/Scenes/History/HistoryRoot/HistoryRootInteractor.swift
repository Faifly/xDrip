//
//  HistoryRootInteractor.swift
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

protocol HistoryRootBusinessLogic {
    func doLoad(request: HistoryRoot.Load.Request)
    func doCancel(request: HistoryRoot.Cancel.Request)
    func doChangeChartTimeFrame(request: HistoryRoot.ChangeEntriesChartTimeFrame.Request)
    func doChangeChartDate(request: HistoryRoot.ChangeEntriesChartDate.Request)
}

protocol HistoryRootDataStore: AnyObject {
}

final class HistoryRootInteractor: HistoryRootBusinessLogic, HistoryRootDataStore {
    var presenter: HistoryRootPresentationLogic?
    var router: HistoryRootRoutingLogic?
    
    private let glucoseDataWorker: HomeGlucoseDataWorkerProtocol
    private var timeline: HistoryRoot.Timeline = .last14Days
    private var selectedDate = Date()
    
    private var chartDate: Date? {
        return timeline == .last14Days ? nil : selectedDate
    }
    
    private var interval: TimeInterval {
        return timeline == .last14Days ? TimeInterval(hours: 14.0 * 24.0) : .secondsPerDay
    }
    
    init() {
        glucoseDataWorker = HomeGlucoseDataWorker()
    }
    
    // MARK: Do something
    
    func doLoad(request: HistoryRoot.Load.Request) {
        let response = HistoryRoot.Load.Response(globalTimeInterval: interval)
        presenter?.presentLoad(response: response)
        updateGlucoseChartData()
    }
    
    func doCancel(request: HistoryRoot.Cancel.Request) {
        router?.dismissSelf()
    }
    
    func doChangeChartTimeFrame(request: HistoryRoot.ChangeEntriesChartTimeFrame.Request) {
        timeline = request.timeline
        let response = HistoryRoot.ChangeEntriesChartTimeFrame.Response(timeInterval: interval)
        presenter?.presentChartTimeFrameChange(response: response)
        updateGlucoseChartData()
    }
    
    func doChangeChartDate(request: HistoryRoot.ChangeEntriesChartDate.Request) {
        selectedDate = request.date
        
        updateGlucoseChartData()
    }
    
    // MARK: Logic
    
    private func updateGlucoseChartData() {
        var glucoseData = [GlucoseReading]()
        var basalValues = [InsulinEntry]()
        var chartEntries = [InsulinEntry]()
        if timeline == .last14Days {
            glucoseData = glucoseDataWorker.fetchGlucoseData(for: 14 * 24)
            basalValues = BasalChartDataWorker.fetchBasalData(for: 14 * 24)
            chartEntries = BasalChartDataWorker.calculateChartValues(for: 14 * 24)
        } else {
            glucoseData = glucoseDataWorker.fetchGlucoseData(for: selectedDate)
            basalValues = BasalChartDataWorker.fetchBasalData(for: selectedDate)
            chartEntries = BasalChartDataWorker.calculateChartValues(for: selectedDate)
        }
        
        let response = HistoryRoot.GlucoseDataUpdate.Response(
            glucoseData: glucoseData,
            intervalGlucoseData: glucoseData,
            basalDisplayMode: User.current.settings.chart?.basalDisplayMode ?? .notShown,
            insulinData: basalValues,
            chartPointsData: chartEntries,
            date: chartDate
        )
        presenter?.presentGlucoseData(response: response)
    }
}

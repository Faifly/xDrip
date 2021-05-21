//
//  HomeInteractor.swift
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

protocol HomeBusinessLogic {
    func doLoad(request: Home.Load.Request)
    func doShowEntriesList(request: Home.ShowEntriesList.Request)
    func doChangeGlucoseChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request)
    func doChangeBolusChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request)
    func doChangeCarbsChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request)
    func doUpdateGlucoseDataView(request: Home.GlucoseDataViewUpdate.Request)
}

protocol HomeDataStore: AnyObject {
}

// swiftlint:disable discouraged_optional_collection

final class HomeInteractor: HomeBusinessLogic, HomeDataStore {
    var presenter: HomePresentationLogic?
    var router: HomeRoutingLogic?
    
    private let glucoseDataWorker: HomeGlucoseDataWorkerProtocol
    private let sensorStateWorker: HomeSensorStateWorkerLogic
    private var basalEntriesObserver: [NSObjectProtocol]?
    private var activeInsulinObserver: [NSObjectProtocol]?
    private var activeCarbsObserver: [NSObjectProtocol]?
    private var dataSectionObserver: [NSObjectProtocol]?
    private var deviceModeObserver: [NSObjectProtocol]?
    private var hours: Int = 1
    
    private var timer: Timer?
    private var currentGlucoseTimer: Timer?
    
    init() {
        glucoseDataWorker = HomeGlucoseDataWorker()
        sensorStateWorker = HomeSensorStateWorker()
        
        subscribeToEntriesWorkersEvents()
        subscribeToNotifications()
    }
    
    private func subscribeToEntriesWorkersEvents() {
        glucoseDataWorker.glucoseDataHandler = { [weak self] in
            guard let self = self else { return }
            self.updateGlucoseCurrentInfo()
            self.updateGlucoseChartData()
        }
        InsulinEntriesWorker.bolusDataHandler = { [weak self] in
            guard let self = self else { return }
            self.updateBolusChartData()
        }
        InsulinEntriesWorker.basalDataHandler = { [weak self] in
            guard let self = self else { return }
            self.updateGlucoseChartData()
        }
        CarbEntriesWorker.carbsDataHandler = { [weak self] in
            guard let self = self else { return }
            self.updateCarbsChartData()
        }
    }
    
    private func subscribeToNotifications() {
        basalEntriesObserver = NotificationCenter.default.subscribe(
            forSettingsChange: [.basalRelated, .unit, .chart],
            notificationHandler: { [weak self] _ in
                self?.updateGlucoseCurrentInfo()
                self?.updateGlucoseChartData()
            }
        )
        
        activeInsulinObserver = NotificationCenter.default.subscribe(
            forSettingsChange: [.activeInsulin],
            notificationHandler: { [weak self] _ in
                guard let self = self else { return }
                self.updateBolusChartData()
            }
        )
        
        activeCarbsObserver = NotificationCenter.default.subscribe(
            forSettingsChange: [.activeCarbs],
            notificationHandler: { [weak self] _ in
                guard let self = self else { return }
                self.updateCarbsChartData()
            }
        )
        
        dataSectionObserver = NotificationCenter.default.subscribe(
            forSettingsChange: [.data],
            notificationHandler: { [weak self] _ in
                guard let self = self else { return }
                self.updateGlucoseChartData()
            }
        )
        
        deviceModeObserver = NotificationCenter.default.subscribe(
            forSettingsChange: [.deviceMode],
            notificationHandler: { [weak self] _ in
                guard let self = self else { return }
                self.updateGlucoseChartData()
                self.updateGlucoseCurrentInfo()
                self.updateBolusChartData()
                self.updateCarbsChartData()
            }
        )
    }
    
    private func setupUpdateTimer(with state: Home.SensorState) {
        switch state {
        case .started:
            timer?.invalidate()
            timer = nil
        case .stopped:
            if timer == nil {
                timer = Timer.scheduledTimer(
                    withTimeInterval: 60.0,
                    repeats: true) { [weak self] _ in
                        guard let self = self else { return }
                        self.updateGlucoseChartData()
                        self.updateBolusChartData()
                        self.updateCarbsChartData()
                }
            }
        default:
            break
        }
    }
    
    private func setupCurrentGlucoseTimer() {
        if currentGlucoseTimer == nil {
            currentGlucoseTimer = Timer.scheduledTimer(
                withTimeInterval: 60.0,
                repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.updateGlucoseCurrentInfo()
            }
        }
    }
    
    // MARK: Do something
    
    func doLoad(request: Home.Load.Request) {
        let response = Home.Load.Response()
        presenter?.presentLoad(response: response)
        updateGlucoseCurrentInfo()
        updateGlucoseChartData()
        updateBolusChartData()
        updateCarbsChartData()
        setupCurrentGlucoseTimer()
        sensorStateWorker.subscribeForSensorStateChange { [weak self] state in
            let response = Home.UpdateSensorState.Response(state: state)
            self?.presenter?.presentUpdateSensorState(response: response)
            self?.setupUpdateTimer(with: state)
        }
    }
    
    func doShowEntriesList(request: Home.ShowEntriesList.Request) {
        switch request.entriesType {
        case .bolus:
            router?.routeToBolusEntriesList()
        case .carbs:
            router?.routeToCarbsEntriesList()
        case .training:
            router?.routeToTrainingEntriesList()
        case .basal:
            router?.routeToBasalEntriesList()
        default:
            break
        }
    }
    
    func doChangeGlucoseChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request) {
        hours = request.hours
        let response = Home.ChangeEntriesChartTimeFrame.Response(
            timeInterval: .secondsPerHour * TimeInterval(request.hours)
        )
        presenter?.presentGlucoseChartTimeFrameChange(response: response)
        updateGlucoseChartData()
    }
    
    func doUpdateGlucoseDataView(request: Home.GlucoseDataViewUpdate.Request) {
        let allReadings = GlucoseReading.allForCurrentMode()
        let response = Home.GlucoseDataViewUpdate.Response(
            intervalGlucoseData: glucoseDataWorker.fetchGlucoseData(for: request.dateInterval, readings: allReadings)
        )
        presenter?.presentUpdateGlucoseDataView(response: response)
    }
    
    // MARK: Logic
    
    private func updateGlucoseChartData() {
        let allReadings = GlucoseReading.allForCurrentMode()
        let response = Home.GlucoseDataUpdate.Response(
            glucoseData: glucoseDataWorker.fetchGlucoseData(for: 24, readings: allReadings),
            basalDisplayMode: User.current.settings.chart?.basalDisplayMode ?? .notShown,
            insulinData: BasalChartDataWorker.fetchBasalData(for: 24),
            chartPointsData: BasalChartDataWorker.calculateChartValues(for: 24)
        )
        presenter?.presentGlucoseData(response: response)
    }
    
    private func updateGlucoseCurrentInfo() {
        let allReadings = GlucoseReading.allForCurrentMode()
        let response = Home.GlucoseCurrentInfo.Response(lastGlucoseReading: glucoseDataWorker
                                                            .fetchLastGlucoseReading(readings: allReadings))
        presenter?.presentGlucoseCurrentInfo(response: response)
    }
    
    func doChangeBolusChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request) {
        let response = Home.ChangeEntriesChartTimeFrame.Response(
            timeInterval: .secondsPerHour * TimeInterval(request.hours)
        )
        presenter?.presentBolusChartTimeFrameChange(response: response)
    }
    
    func doChangeCarbsChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request) {
        let response = Home.ChangeEntriesChartTimeFrame.Response(
            timeInterval: .secondsPerHour * TimeInterval(request.hours)
        )
        presenter?.presentCarbsChartTimeFrameChange(response: response)
    }
    
    private func updateBolusChartData() {
        var insulinData: [InsulinEntry] = []
        let isShown = User.current.settings.chart?.showActiveInsulin == true
            && User.current.settings.deviceMode != .follower
        if isShown {
            insulinData = InsulinEntriesWorker.fetchAllBolusEntries().filter {
                $0.isValid
            }
        }
        let response = Home.BolusDataUpdate.Response(insulinData: insulinData, isShown: isShown)
        presenter?.presentBolusData(response: response)
    }
    
    private func updateCarbsChartData() {
        var carbsData: [CarbEntry] = []
        let isShown = User.current.settings.chart?.showActiveCarbs == true
            && User.current.settings.deviceMode != .follower
        if  isShown {
            carbsData = CarbEntriesWorker.fetchAllCarbEntries().filter { $0.isValid }
        }
        let response = Home.CarbsDataUpdate.Response(carbsData: carbsData, isShown: isShown)
        presenter?.presentCarbsData(response: response)
    }
}

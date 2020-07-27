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
    func doChangeGlucoseChartTimeFrame(request: Home.ChangeGlucoseChartTimeFrame.Request)
}

protocol HomeDataStore: AnyObject {
}

// swiftlint:disable discouraged_optional_collection

final class HomeInteractor: HomeBusinessLogic, HomeDataStore {
    var presenter: HomePresentationLogic?
    var router: HomeRoutingLogic?
    
    private let glucoseDataWorker: HomeGlucoseDataWorkerProtocol
    private let warmUpWorker: HomeWarmUpWorkerLogic
    private var basalEntriesObserver: [NSObjectProtocol]?
    
    init() {
        glucoseDataWorker = HomeGlucoseDataWorker()
        warmUpWorker = HomeWarmUpWorker()
        
        glucoseDataWorker.glucoseDataHandler = { [weak self] in
            guard let self = self else { return }
            self.updateGlucoseCurrentInfo()
            self.updateGlucoseChartData()
        }
        
        basalEntriesObserver = NotificationCenter.default.subscribe(
            forSettingsChange: [.basalRelated, .unit],
            notificationHandler: { [weak self] _ in
                self?.updateGlucoseCurrentInfo()
                self?.updateGlucoseChartData()
            }
        )
    }
    
    // MARK: Do something
    
    func doLoad(request: Home.Load.Request) {
        let response = Home.Load.Response()
        presenter?.presentLoad(response: response)
        updateGlucoseCurrentInfo()
        updateGlucoseChartData()
        warmUpWorker.subscribeForWarmUpStateChange { [weak self] state in
            let response = Home.WarmUp.Response(state: state)
            self?.presenter?.presentWarmUp(response: response)
        }
    }
    
    func doShowEntriesList(request: Home.ShowEntriesList.Request) {
        switch request.entriesType {
        case .bolus:
            router?.routeToBolusEntriesList()
        case .carbs:
            router?.routeToCarbsEntriesList()
        default:
            break
        }
    }
    
    func doChangeGlucoseChartTimeFrame(request: Home.ChangeGlucoseChartTimeFrame.Request) {
        let response = Home.ChangeGlucoseChartTimeFrame.Response(
            timeInterval: .secondsPerHour * TimeInterval(request.hours)
        )
        presenter?.presentGlucoseChartTimeFrameChange(response: response)
    }
    
    // MARK: Logic
    
    private func updateGlucoseChartData() {
        let response = Home.GlucoseDataUpdate.Response(
            glucoseData: glucoseDataWorker.fetchGlucoseData(),
            basalDisplayMode: User.current.settings.chart?.basalDisplayMode ?? .notShown,
            insulinData: BasalChartDataWorker.fetchBasalData(),
            chartPointsData: BasalChartDataWorker.calculateChartValues()
        )
        self.presenter?.presentGlucoseData(response: response)
    }
    
    private func updateGlucoseCurrentInfo() {
        let response = Home.GlucoseCurrentInfo.Response(lastGlucoseReading: glucoseDataWorker.fetchLastGlucoseReading())
        presenter?.presentGlucoseCurrentInfo(response: response)
    }
}

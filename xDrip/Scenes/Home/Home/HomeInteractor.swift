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

final class HomeInteractor: HomeBusinessLogic, HomeDataStore {
    var presenter: HomePresentationLogic?
    var router: HomeRoutingLogic?
    
    private let glucoseDataWorker: HomeGlucoseDataWorkerProtocol
    
    init() {
        glucoseDataWorker = HomeGlucoseDataWorker()
        glucoseDataWorker.glucoseDataHandler = { [weak self] in
            self?.updateGlucoseCurrentInfo()
            self?.updateGlucoseChartData()
        }
    }
    
    // MARK: Do something
    
    func doLoad(request: Home.Load.Request) {
        let response = Home.Load.Response()
        presenter?.presentLoad(response: response)
        updateGlucoseCurrentInfo()
        updateGlucoseChartData()
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
        let response = Home.GlucoseDataUpdate.Response(glucoseData: glucoseDataWorker.fetchGlucoseData())
        self.presenter?.presentGlucoseData(response: response)
    }
    
    private func updateGlucoseCurrentInfo() {
        let response = Home.GlucoseCurrentInfo.Response(lastGlucoseReading: glucoseDataWorker.fetchLastGlucoseReading())
        self.presenter?.presentGlucoseCurrentInfo(response: response)
    }
}

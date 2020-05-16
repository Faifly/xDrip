//
//  RootInteractor.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol RootBusinessLogic {
    func doLoad(request: Root.Load.Request)
    func doTabSelection(request: Root.TabSelection.Request)
    func doShowAddEntry(request: Root.ShowAddEntry.Request)
    func doShowInitialSetupIfNeeded(request: Root.InitialSetup.Request)
}

protocol RootDataStore: AnyObject {
}

final class RootInteractor: RootBusinessLogic, RootDataStore {
    var presenter: RootPresentationLogic?
    var router: RootRoutingLogic?
    
    private let entryTypes: [Root.EntryType] = [.food, .bolus, .carbs, .training]
    
    private let calibrationWorker: RootCalibrationValidatorProtocol
    
    // MARK: Do something
    
    init() {
        calibrationWorker = RootCalibrationValidatorWorker()
    }
    
    func doLoad(request: Root.Load.Request) {
        let response = Root.Load.Response()
        presenter?.presentLoad(response: response)
    }
    
    func doTabSelection(request: Root.TabSelection.Request) {
        switch request.button {
        case .calibration: startCalibrationFlow()
        case .chart: router?.routeToStats()
        case .history: router?.routeToHistory()
        case .settings: router?.routeToSettings()
        case .plus:
            let response = Root.ShowAddEntryOptionsList.Response(types: entryTypes)
            presenter?.presentAddEntry(response: response)
        }
    }
    
    func doShowAddEntry(request: Root.ShowAddEntry.Request) {
        _ = entryTypes[request.index]
        
        // TO DO: - add route to add entry
    }
    
    func doShowInitialSetupIfNeeded(request: Root.InitialSetup.Request) {
        if !User.current.isInitialSetupDone {
            router?.routeToInitialSetup()
        }
    }
    
    // MARK: Logic
    
    private func startCalibrationFlow() {
        switch calibrationWorker.isAllowedToCalibrate {
        case .allowed:
            router?.routeToCalibration()
        case let .notAllowed(errorTitle, errorMessage):
            router?.showCalibrationError(title: errorTitle, message: errorMessage)
        }
    }
}

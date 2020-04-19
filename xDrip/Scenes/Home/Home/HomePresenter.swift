//
//  HomePresenter.swift
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

protocol HomePresentationLogic {
    func presentLoad(response: Home.Load.Response)
    func presentGlucoseData(response: Home.GlucoseDataUpdate.Response)
    func presentGlucoseChartTimeFrameChange(response: Home.ChangeGlucoseChartTimeFrame.Response)
}

final class HomePresenter: HomePresentationLogic {
    weak var viewController: HomeDisplayLogic?
    
    private let glucoseFormattingWorker: HomeGlucoseFormattingWorkerProtocol
    
    init() {
        glucoseFormattingWorker = HomeGlucoseFormattingWorker()
    }
    
    // MARK: Do something
    
    func presentLoad(response: Home.Load.Response) {
        let viewModel = Home.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    func presentGlucoseData(response: Home.GlucoseDataUpdate.Response) {
        let values = glucoseFormattingWorker.formatEntries(response.glucoseData)
        let unit = User.current.settings.unit.label
        let viewModel = Home.GlucoseDataUpdate.ViewModel(glucoseValues: values, unit: unit)
        viewController?.displayGlucoseData(viewModel: viewModel)
    }
    
    func presentGlucoseChartTimeFrameChange(response: Home.ChangeGlucoseChartTimeFrame.Response) {
        let viewModel = Home.ChangeGlucoseChartTimeFrame.ViewModel(timeInterval: response.timeInterval)
        viewController?.displayGlucoseChartTimeFrame(viewModel: viewModel)
    }
}

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
    func presentGlucoseCurrentInfo(response: Home.GlucoseCurrentInfo.Response)
    func presentGlucoseChartTimeFrameChange(response: Home.ChangeEntriesChartTimeFrame.Response)
    func presentBolusData(response: Home.BolusDataUpdate.Response)
    func presentBolusChartTimeFrameChange(response: Home.ChangeEntriesChartTimeFrame.Response)
    func presentCarbsData(response: Home.CarbsDataUpdate.Response)
    func presentCarbsChartTimeFrameChange(response: Home.ChangeEntriesChartTimeFrame.Response)
    func presentWarmUp(response: Home.WarmUp.Response)
}

final class HomePresenter: HomePresentationLogic {
    weak var viewController: HomeDisplayLogic?
    
    private let glucoseFormattingWorker: HomeGlucoseFormattingWorkerProtocol
    private let homeEntriesFormattingWorker: HomeEntriesFormattingWorkerProtocol
    
    init() {
        glucoseFormattingWorker = HomeGlucoseFormattingWorker()
        homeEntriesFormattingWorker = HomeEntriesFormattingWorker()
    }
    
    // MARK: Do something
    
    func presentLoad(response: Home.Load.Response) {
        let viewModel = Home.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    func presentGlucoseData(response: Home.GlucoseDataUpdate.Response) {
        let values = glucoseFormattingWorker.formatEntries(response.glucoseData)
        let basal = glucoseFormattingWorker.formatEntries(response.insulinData)
        let stroke = glucoseFormattingWorker.formatEntries(response.chartPointsData)
        let unit = User.current.settings.unit.label
        let viewModel = Home.GlucoseDataUpdate.ViewModel(
            glucoseValues: values,
            basalDisplayMode: response.basalDisplayMode,
            basalValues: basal,
            strokeChartBasalValues: stroke,
            unit: unit
        )
        viewController?.displayGlucoseData(viewModel: viewModel)
    }
    
    func presentGlucoseChartTimeFrameChange(response: Home.ChangeEntriesChartTimeFrame.Response) {
        let viewModel = Home.ChangeGlucoseEntriesChartTimeFrame.ViewModel(timeInterval: response.timeInterval)
        viewController?.displayGlucoseChartTimeFrame(viewModel: viewModel)
    }
    
    func presentGlucoseCurrentInfo(response: Home.GlucoseCurrentInfo.Response) {
        let value = glucoseFormattingWorker.formatEntry(response.lastGlucoseReading)
        let viewModel = Home.GlucoseCurrentInfo.ViewModel(
            glucoseIntValue: value.glucoseIntValue,
            glucoseDecimalValue: value.glucoseDecimalValue,
            slopeValue: value.slopeValue,
            lastScanDate: value.lastScanDate,
            difValue: value.difValue,
            severityColor: value.severityColor)
        viewController?.displayGlucoseCurrentInfo(viewModel: viewModel)
    }
    
    func presentBolusData(response: Home.BolusDataUpdate.Response) {
        let entry = homeEntriesFormattingWorker.formatBolusResponse(response)
        let chartButtonTitle = homeEntriesFormattingWorker.getChartButtonTitle(.bolus)
        let isShown = User.current.settings.chart?.showActiveInsulin ?? true
        let viewModel = Home.BolusDataUpdate.ViewModel(chartTitle: entry.title,
                                                       chartButtonTitle: chartButtonTitle,
                                                       entries: entry.entries,
                                                       unit: entry.unit,
                                                       color: entry.color,
                                                       isShown: isShown)
        viewController?.displayBolusData(viewModel: viewModel)
    }
    
    func presentBolusChartTimeFrameChange(response: Home.ChangeEntriesChartTimeFrame.Response) {
        homeEntriesFormattingWorker.setTimeInterval(response.timeInterval)
        let chartButtonTitle = homeEntriesFormattingWorker.getChartButtonTitle(.bolus)
        let viewModel = Home.ChangeEntriesChartTimeFrame.ViewModel(timeInterval: response.timeInterval,
                                                                   buttonTitle: chartButtonTitle)
        viewController?.displayBolusChartTimeFrame(viewModel: viewModel)
    }
    
    func presentCarbsData(response: Home.CarbsDataUpdate.Response) {
        let entry = homeEntriesFormattingWorker.formatCarbsResponse(response)
        let chartButtonTitle = homeEntriesFormattingWorker.getChartButtonTitle(.carbs)
        let isShown = User.current.settings.chart?.showActiveCarbs ?? true
        let viewModel = Home.CarbsDataUpdate.ViewModel(chartTitle: entry.title,
                                                       chartButtonTitle: chartButtonTitle,
                                                       entries: entry.entries,
                                                       unit: entry.unit,
                                                       color: entry.color,
                                                       isShown: isShown)
        viewController?.displayCarbsData(viewModel: viewModel)
    }
    
    func presentCarbsChartTimeFrameChange(response: Home.ChangeEntriesChartTimeFrame.Response) {
        homeEntriesFormattingWorker.setTimeInterval(response.timeInterval)
        let chartButtonTitle = homeEntriesFormattingWorker.getChartButtonTitle(.carbs)
        let viewModel = Home.ChangeEntriesChartTimeFrame.ViewModel(timeInterval: response.timeInterval,
                                                                   buttonTitle: chartButtonTitle)
        viewController?.displayCarbsChartTimeFrame(viewModel: viewModel)
    }
    
    func presentWarmUp(response: Home.WarmUp.Response) {
        let hours: Int
        let minutes: Int
        
        if let totalMinutes = response.state.minutesLeft {
            if totalMinutes > 60 {
                hours = totalMinutes / 60
                minutes = totalMinutes - hours * 60
            } else {
                hours = 0
                minutes = totalMinutes
            }
        } else {
            hours = 0
            minutes = 0
        }
        
        let viewModel = Home.WarmUp.ViewModel(
            shouldShowWarmUp: response.state.isWarmingUp,
            warmUpLeftHours: hours,
            warmUpLeftMinutes: minutes
        )
        viewController?.displayWarmUp(viewModel: viewModel)
    }
}

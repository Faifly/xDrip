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
    func presentUpdateSensorState(response: Home.UpdateSensorState.Response)
    func presentUpdateGlucoseDataView(response: Home.GlucoseDataViewUpdate.Response)
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
        let last2Readings = GlucoseReading.lastReadings(2, for: response.lastGlucoseReading?.deviceMode ?? .main)
        let value = glucoseFormattingWorker.formatEntry(response.lastGlucoseReading, last2Readings: last2Readings)
        let viewModel = Home.GlucoseCurrentInfo.ViewModel(
            glucoseIntValue: value.glucoseIntValue,
            glucoseDecimalValue: value.glucoseDecimalValue,
            slopeValue: value.slopeValue,
            lastScanDate: value.lastScanDate,
            difValue: value.difValue,
            severityColor: value.severityColor,
            isOutdated: value.isOutdated)
        viewController?.displayGlucoseCurrentInfo(viewModel: viewModel)
    }
    
    func presentBolusData(response: Home.BolusDataUpdate.Response) {
        let entry = homeEntriesFormattingWorker.formatBolusResponse(response)
        let chartButtonTitle = homeEntriesFormattingWorker.getChartButtonTitle(.bolus)
        let chartShouldBeHidden = homeEntriesFormattingWorker.getChartShouldBeShown()
        let viewModel = Home.BolusDataUpdate.ViewModel(chartTitle: entry.title,
                                                       chartButtonTitle: chartButtonTitle,
                                                       entries: entry.entries,
                                                       unit: entry.unit,
                                                       color: entry.color,
                                                       isShown: response.isShown,
                                                       isChartShown: chartShouldBeHidden)
        viewController?.displayBolusData(viewModel: viewModel)
    }
    
    func presentBolusChartTimeFrameChange(response: Home.ChangeEntriesChartTimeFrame.Response) {
        homeEntriesFormattingWorker.setTimeInterval(response.timeInterval)
        let chartButtonTitle = homeEntriesFormattingWorker.getChartButtonTitle(.bolus)
        let chartShouldBeShown = homeEntriesFormattingWorker.getChartShouldBeShown()
        let viewModel = Home.ChangeEntriesChartTimeFrame.ViewModel(timeInterval: response.timeInterval,
                                                                   buttonTitle: chartButtonTitle,
                                                                   isChartShown: chartShouldBeShown)
        viewController?.displayBolusChartTimeFrame(viewModel: viewModel)
    }
    
    func presentCarbsData(response: Home.CarbsDataUpdate.Response) {
        let entry = homeEntriesFormattingWorker.formatCarbsResponse(response)
        let chartButtonTitle = homeEntriesFormattingWorker.getChartButtonTitle(.carbs)
        let chartShouldBeHidden = homeEntriesFormattingWorker.getChartShouldBeShown()
        let viewModel = Home.CarbsDataUpdate.ViewModel(chartTitle: entry.title,
                                                       chartButtonTitle: chartButtonTitle,
                                                       entries: entry.entries,
                                                       unit: entry.unit,
                                                       color: entry.color,
                                                       isShown: response.isShown,
                                                       isChartShown: chartShouldBeHidden)
        viewController?.displayCarbsData(viewModel: viewModel)
    }
    
    func presentCarbsChartTimeFrameChange(response: Home.ChangeEntriesChartTimeFrame.Response) {
        homeEntriesFormattingWorker.setTimeInterval(response.timeInterval)
        let chartButtonTitle = homeEntriesFormattingWorker.getChartButtonTitle(.carbs)
        let chartShouldBeShown = homeEntriesFormattingWorker.getChartShouldBeShown()
        let viewModel = Home.ChangeEntriesChartTimeFrame.ViewModel(timeInterval: response.timeInterval,
                                                                   buttonTitle: chartButtonTitle,
                                                                   isChartShown: chartShouldBeShown)
        viewController?.displayCarbsChartTimeFrame(viewModel: viewModel)
    }
    
    func presentUpdateSensorState(response: Home.UpdateSensorState.Response) {
        let string: NSMutableAttributedString
        switch response.state {
        case let .warmingUp(minutesLeft):
            string = createWarmUpMessage(for: minutesLeft)
            
        case .started:
            let viewModel = Home.UpdateSensorState.ViewModel(
                shouldShow: false,
                text: NSMutableAttributedString(string: "")
            )
            
            viewController?.displayUpdateSensorState(viewModel: viewModel)
            return
            
        case .waitingReadings:
            string = NSMutableAttributedString(
                string: "home_sensor_waiting_readings".localized,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                    .foregroundColor: UIColor.tabBarBlueColor
                ]
            )
            
        case .stopped:
            string = NSMutableAttributedString(
                string: "home_sensor_stopped".localized,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                    .foregroundColor: UIColor.tabBarRedColor
                ]
            )
            
        case let .calibrationState(state):
            guard let state = state else { return }
            if state == .okay {
                let viewModel = Home.UpdateSensorState.ViewModel(
                    shouldShow: false,
                    text: NSMutableAttributedString(string: "")
                )
                viewController?.displayUpdateSensorState(viewModel: viewModel)
                return
            } else {
                string = NSMutableAttributedString(
                    string: state.rawValue.description,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                        .foregroundColor: UIColor.tabBarRedColor
                    ]
                )
            }
        }
        
        let viewModel = Home.UpdateSensorState.ViewModel(
            shouldShow: true,
            text: string
        )
        
        viewController?.displayUpdateSensorState(viewModel: viewModel)
    }
    
    private func createWarmUpMessage(for minutesLeft: Int) -> NSMutableAttributedString {
        let timeLabel: String
        if minutesLeft > 60 {
            let hours = minutesLeft / 60
            let minutes = minutesLeft - hours * 60
            
            timeLabel = String(
                format: "home_warmingup_time_label_hours".localized,
                hours,
                minutes
            )
        } else {
            timeLabel = String(
                format: "home_warmingup_time_label_minutes".localized,
                minutesLeft
            )
        }
        
        let string = NSMutableAttributedString()
        string.append(
            NSAttributedString(
                string: "home_warmingup_initial_label".localized,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                    .foregroundColor: UIColor.highEmphasisText
                ]
            )
        )
        string.append(
            NSAttributedString(
                string: timeLabel,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                    .foregroundColor: UIColor.tabBarRedColor
                ]
            )
        )
        
        return string
    }
    
    func presentUpdateGlucoseDataView(response: Home.GlucoseDataViewUpdate.Response) {
        let dataSection = glucoseFormattingWorker.formatDataSection(response.intervalGlucoseData)
        
        let viewModel = Home.GlucoseDataViewUpdate.ViewModel(
            dataSection: dataSection
        )
        viewController?.displayUpdateGlucoseDataView(viewModel: viewModel)
    }
}

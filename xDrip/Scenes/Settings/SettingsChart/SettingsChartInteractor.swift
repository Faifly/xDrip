//
//  SettingsChartInteractor.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsChartBusinessLogic {
    func doLoad(request: SettingsChart.Load.Request)
}

protocol SettingsChartDataStore: AnyObject {
}

final class SettingsChartInteractor: SettingsChartBusinessLogic, SettingsChartDataStore {
    var presenter: SettingsChartPresentationLogic?
    var router: SettingsChartRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsChart.Load.Request) {
        let response = SettingsChart.Load.Response(
            switchValueChangedHandler: handleSwitchValueChanged(_:_:),
            singleSelectionHandler: handleSingleSelection(_:)
        )
        
        presenter?.presentLoad(response: response)
    }
    
    private func handleSwitchValueChanged(_ field: SettingsChart.Field, _ value: Bool) {
        let settings = User.current.settings.chart
        
        switch field {
        case .activeInsulin: settings?.updateShowActiveInsulin(value)
        case .activeCarbs: settings?.updateShowActiveCarbs(value)
        case .data: settings?.updateShowData(value)
        }
    }
    
    private func handleSingleSelection(_ value: Int) {
        guard let mode = ChartSettings.BasalDisplayMode(rawValue: value) else { return }
        let settings = User.current.settings.chart
        settings?.updateBasalDispalyMode(mode)
    }
}

//
//  SettingsChartRangesInteractor.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsChartRangesBusinessLogic {
    func doUpdateData(request: SettingsChartRanges.UpdateData.Request)
}

protocol SettingsChartRangesDataStore: AnyObject {    
}

final class SettingsChartRangesInteractor: SettingsChartRangesBusinessLogic, SettingsChartRangesDataStore {
    var presenter: SettingsChartRangesPresentationLogic?
    var router: SettingsChartRangesRoutingLogic?
    
    // MARK: Do something
    
    func doUpdateData(request: SettingsChartRanges.UpdateData.Request) {
        let settings = User.current.settings
        let response = SettingsChartRanges.UpdateData.Response(
            settings: settings ?? Settings(),
            pickerValueChanged: handlePickerValueChanged(_:_:)
        )
        presenter?.presentUpdateData(response: response)
    }
    
    private func handlePickerValueChanged(_ field: SettingsChartRanges.Field, _ values: [Double]) {
        guard values.count > 1 else { return }
        
        let settings = User.current.settings
        let unit = settings?.unit ?? .default
        let step = unit.pickerStep
        let convertedValues = values.map { GlucoseUnit.convertToDefault($0) }
        
        switch field {
        case .notHigherLess:
            settings?.configureWarningLevel(.high, value: convertedValues[0])
            settings?.configureWarningLevel(.low, value: convertedValues[1])
            
            if let urgentHigh = settings?.warningLevelValue(for: .urgentHigh),
                urgentHigh <= values[0] {
                let value = GlucoseUnit.convertToDefault(values[0] + 2 * step)
                settings?.configureWarningLevel(.urgentHigh, value: value)
            }
            
            if let urgentLow = settings?.warningLevelValue(for: .urgentLow),
                urgentLow >= values[1] {
                let value = GlucoseUnit.convertToDefault((values[1] - 2 * step))
                settings?.configureWarningLevel(.urgentLow, value: value)
            }
        case .urgent:
            settings?.configureWarningLevel(.urgentHigh, value: convertedValues[0])
            settings?.configureWarningLevel(.urgentLow, value: convertedValues[1])
        default:
            break
        }
        
        doUpdateData(request: SettingsChartRanges.UpdateData.Request())
    }
}

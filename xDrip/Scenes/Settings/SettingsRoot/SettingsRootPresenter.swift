//
//  SettingsRootPresenter.swift
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

protocol SettingsRootPresentationLogic {
    func presentLoad(response: SettingsRoot.Load.Response)
}

final class SettingsRootPresenter: SettingsRootPresentationLogic {
    weak var viewController: SettingsRootDisplayLogic?
    private var dataSource = [BaseSettingsPickerViewController]()
    
    // MARK: Do something
    
    func presentLoad(response: SettingsRoot.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(sections: [
            createTestSection(),
            createApplicationSetupSection(response: response),
            createProfileSetupSection(response: response)
        ])
        
        let viewModel = SettingsRoot.Load.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    private func createApplicationSetupSection(response: SettingsRoot.Load.Response) -> BaseSettings.Section {
        let cells: [BaseSettings.Cell] = [
            createDisclosureCell(.chartSettings, detailText: nil, selectionHandler: response.selectionHandler),
            createDisclosureCell(.alert, detailText: nil, selectionHandler: response.selectionHandler),
            createDisclosureCell(.cloudUpload, detailText: nil, selectionHandler: response.selectionHandler),
            createDisclosureCell(.modeSettings, detailText: "Master/Follower", selectionHandler: response.selectionHandler),
            createDisclosureCell(.sensor, detailText: nil, selectionHandler: response.selectionHandler),
            createDisclosureCell(.transmitter, detailText: nil, selectionHandler: response.selectionHandler)
        ]
        
        return BaseSettings.Section.normal(cells: cells, header: "APPLICATION SETUP", footer: nil)
    }
    
    private func createProfileSetupSection(response: SettingsRoot.Load.Response) -> BaseSettings.Section {
        let cells: [BaseSettings.Cell] = [
            createDisclosureCell(.rangeSelection, detailText: nil, selectionHandler: response.selectionHandler),
            createDisclosureCell(.userType, detailText: "Pen/Pump", selectionHandler: response.selectionHandler),
            createDisclosureCell(.units, detailText: nil, selectionHandler: response.selectionHandler),
            createDisclosureCell(.carbsDurationTime, detailText: nil, selectionHandler: response.selectionHandler),
            createDisclosureCell(.insulinDurationTime, detailText: nil, selectionHandler: response.selectionHandler),
        ]
        
        return BaseSettings.Section.normal(cells: cells, header: "PROFILE SETUP", footer: nil)
    }
    
    private func createTestSection() -> BaseSettings.Section {
        let cells: [BaseSettings.Cell] = [
            createRightSwitchCell(.alert, isSwitchOn: Bool.random(), switchHandler: { _ in }),
            createVolumeSliderCell(Float.random(in: 0...1), valueChangedHandler: { _ in }),
            createTextInputCell(.modeSettings, detailText: "test text", textChangeHandler: { _ in }),
            createPickerExpandableCell(.carbsDurationTime, detailText: nil, picker: UIPickerView()),
            createPickerExpandableCell(.insulinDurationTime, detailText: nil, picker: UIDatePicker())
        ]
        
        return BaseSettings.Section.normal(cells: cells, header: "TEST", footer: nil)
    }
    
    private func createDisclosureCell(
        _ field: SettingsRoot.Field,
        detailText: String?,
        selectionHandler: @escaping (SettingsRoot.Field) -> Void) -> BaseSettings.Cell {
        return .disclosure(mainText: field.title, detailText: detailText) {
            selectionHandler(field)
        }
    }
    
    private func createRightSwitchCell(
        _ field: SettingsRoot.Field,
        isSwitchOn: Bool,
        switchHandler: @escaping (Bool) -> Void) -> BaseSettings.Cell {
        return .rightSwitch(text: field.title, isSwitchOn: isSwitchOn) { _ in }
    }
    
    private func createPickerExpandableCell(
        _ field: SettingsRoot.Field,
        detailText: String?,
        picker: UIView) -> BaseSettings.Cell {
        
        if let pickerView = picker as? UIPickerView {
            let data = [
                ["1", "2", "3", "1", "2", "3", "1", "2", "3", "1", "2", "3"],
                ["1", "2", "1", "2", "3", "1", "2", "3"],
                ["mgDl", "mmolL", "mgDl", "mmolL", "mgDl", "mmolL", "mgDl", "mmolL"]
            ]
            let source = BaseSettingsPickerViewController(data: data)
            dataSource.append(source)
            pickerView.dataSource = source
            pickerView.delegate = source
            pickerView.reloadAllComponents()
        }
        
        return .pickerExpandable(mainText: field.title, detailText: nil, picker: picker)
    }
    
    private func createVolumeSliderCell(
        _ value: Float,
        valueChangedHandler: @escaping (Float) -> Void) -> BaseSettings.Cell {
        return .volumeSlider(value: value, changeHandler: valueChangedHandler)
    }
    
    private func createTextInputCell(
        _ field: SettingsRoot.Field,
        detailText: String?,
        textChangeHandler: @escaping (String?) -> Void) -> BaseSettings.Cell {
        return .textInput(mainText: field.title, detailText: detailText, textChangedHandler: textChangeHandler)
    }
}

private extension SettingsRoot.Field {
    var title: String {
        switch self {
        case .chartSettings: return "settings_chart_title".localized
        case .alert: return "settings_alert_title".localized
        case .cloudUpload: return "settings_cloud_upload_title".localized
        case .modeSettings: return "settings_mode_title".localized
        case .sensor: return "settings_sensor_title".localized
        case .transmitter: return "settings_transmitter_title".localized
        case .rangeSelection: return "settings_range_selection_title".localized
        case .userType: return "settings_user_type_title".localized
        case .units: return "settings_units_title".localized
        case .carbsDurationTime: return "settings_carbs_duration_time_title".localized
        case .insulinDurationTime: return "settings_insulin_duration_time_title".localized
        case .nightscoutService: return "settings_nightscout_pump_title".localized
        }
    }
}

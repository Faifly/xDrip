//
//  SettingsAlertRootPresenter.swift
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

protocol SettingsAlertRootPresentationLogic {
    func presentLoad(response: SettingsAlertRoot.Load.Response)
    func presentUpdate(response: SettingsAlertRoot.Load.Response)
}

final class SettingsAlertRootPresenter: SettingsAlertRootPresentationLogic {
    weak var viewController: SettingsAlertRootDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsAlertRoot.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(sections: [
            createTableViewSection(response: response)
        ])
        
        let viewModel = SettingsAlertRoot.Load.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    func presentUpdate(response: SettingsAlertRoot.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(sections: [
            createTableViewSection(response: response)
        ])
        
        let viewModel = SettingsAlertRoot.Load.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayUpdate(viewModel: viewModel)
    }
    
    private func createTableViewSection(response: SettingsAlertRoot.Load.Response) -> BaseSettings.Section {
        let settings = User.current.settings.alert!
        
        var cells: [BaseSettings.Cell] = [
            createRightSwitch(.overrideSystemVolume, isSwitchOn: settings.isSystemVolumeOverriden, switchHandler: response.switchValueChangedHandler)
        ]
        
        if settings.isSystemVolumeOverriden {
            cells.append(
                createVolumeSliderCell(settings.volume, valueChangedHandler: response.sliderValueChangeHandler)
            )
        }
        
        cells.append(contentsOf: [
            createRightSwitch(.overrideMute, isSwitchOn: settings.isMuteOverriden, switchHandler: response.switchValueChangedHandler),
            createRightSwitch(.notificationsOn, isSwitchOn: settings.isNotificationsEnabled, switchHandler: response.switchValueChangedHandler)
        ])
        
        if settings.isNotificationsEnabled {
            cells.append(
                createDisclosureCell(.alertTypes, detailText: nil, selectionHandler: response.selectionHandler)
            )
        }
        
        return .normal(cells: cells, header: nil, footer: "settings_alert_root_tableview_footer".localized)
    }
    
    private func createRightSwitch(
        _ field: SettingsAlertRoot.Field,
        isSwitchOn: Bool,
        switchHandler: @escaping (SettingsAlertRoot.Field, Bool) -> Void) -> BaseSettings.Cell {
        
        return .rightSwitch(text: field.title, isSwitchOn: isSwitchOn) { (value) in
            switchHandler(field, value)
        }
    }
    
    private func createVolumeSliderCell(
        _ value: Float,
        valueChangedHandler: @escaping (Float) -> Void) -> BaseSettings.Cell {
        return .volumeSlider(value: value, changeHandler: valueChangedHandler)
    }
    
    private func createDisclosureCell(
        _ field: SettingsAlertRoot.Field,
        detailText: String?,
        selectionHandler: @escaping () -> Void) -> BaseSettings.Cell {
        return .disclosure(mainText: field.title, detailText: detailText) {
            selectionHandler()
        }
    }
}

private extension SettingsAlertRoot.Field {
    var title: String {
        switch self {
        case .overrideSystemVolume: return "settings_alert_root_override_system_volume".localized
        case .overrideMute: return "settings_alert_root_override_mute".localized
        case .notificationsOn: return "settings_alert_root_notifications_on".localized
        case .alertTypes: return "settings_alert_root_alert_types".localized
        default: return ""
        }
    }
}

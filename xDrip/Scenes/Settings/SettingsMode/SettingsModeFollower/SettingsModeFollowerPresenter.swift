//
//  SettingsModeFollowerPresenter.swift
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

protocol SettingsModeFollowerPresentationLogic {
    func presentLoad(response: SettingsModeFollower.Load.Response)
    func presentUpdate(response: SettingsModeFollower.Update.Response)
}

final class SettingsModeFollowerPresenter: SettingsModeFollowerPresentationLogic {
    weak var viewController: SettingsModeFollowerDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsModeFollower.Load.Response) {
        let viewModel = SettingsModeFollower.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    func presentUpdate(response: SettingsModeFollower.Update.Response) {
        let tableViewModel = BaseSettings.ViewModel(
            sections: [
                createSection(response: response)
            ]
        )
        
        let viewModel = SettingsModeFollower.Update.ViewModel(
            tableViewModel: tableViewModel,
            authButtonMode: response.settings.isFollowerAuthed ? .logout : .login
        )
        viewController?.displayUpdate(viewModel: viewModel)
    }
    
    private func createSection(response: SettingsModeFollower.Update.Response) -> BaseSettings.Section {
        var cells: [BaseSettings.Cell] = [
            createInfoCell(
                .service,
                detailText: "settings_mode_settings_nightscout".localized
            )
        ]
        
        if response.settings.isFollowerAuthed {
            cells.append(
                createInfoCell(
                    .nightscoutUrl,
                    detailText: response.settings.baseURL
                )
            )
            cells.append(
                createInfoCell(
                    .apiSecret,
                    detailText: response.settings.apiSecret
                )
            )
        } else {
            cells.append(
                createTextInputCell(
                    .nightscoutUrl,
                    textFieldText: response.settings.baseURL,
                    placeholder: "settings_nightscout_cloud_configuration_base_url_placeholder".localized,
                    textEditingChangedHandler: { text in
                        response.textEditingChangedHandler(.nightscoutUrl, text)
                    }
                )
            )
            cells.append(
                createTextInputCell(
                    .apiSecret,
                    textFieldText: response.settings.apiSecret,
                    placeholder: "settings_nightscout_cloud_configuration_api_secret_placeholder".localized,
                    textEditingChangedHandler: { text in
                        response.textEditingChangedHandler(.apiSecret, text)
                    }
                )
            )
        }
        
        return .normal(
            cells: cells,
            header: nil,
            footer: "settings_mode_settings_follower_section_footer".localized
        )
    }
    
    private func createInfoCell(_ field: SettingsModeFollower.Field, detailText: String?) -> BaseSettings.Cell {
        return .info(mainText: field.title, detailText: detailText, detailTextColor: nil)
    }
    
    private func createTextInputCell(
        _ field: SettingsModeFollower.Field,
        textFieldText: String?,
        placeholder: String?,
        textEditingChangedHandler: @escaping (String?) -> Void) -> BaseSettings.Cell {
        return .textInput(
            mainText: field.title,
            detailText: nil,
            textFieldText: textFieldText,
            placeholder: placeholder,
            textChangedHandler: textEditingChangedHandler
        )
    }
    
    private func createTimePickerCell(
        _ field: SettingsModeFollower.Field,
        detailText: TimeInterval,
        timePickerValueChanged: @escaping (TimeInterval) -> Void) -> BaseSettings.Cell {
        let detailText = "\(Int(detailText)) " + "settings_mode_settings_follower_time_minutes".localized
        let picker = CustomPickerView(mode: .countDown)
        
        picker.formatValues = { strings in
            guard strings.count > 3 else { return "" }
           
            let hourString = strings[0]
            let minuteString = strings[2]
           
            guard let hour = Double(hourString), let minute = Double(minuteString) else { return "" }
           
            let time = minute * TimeInterval.secondsPerMinute + hour * TimeInterval.secondsPerHour
           
            timePickerValueChanged(TimeInterval(time))
            
            var timeString = "\(Int(time / TimeInterval.secondsPerMinute)) "
            timeString += "settings_mode_settings_follower_time_minutes".localized
            
            return timeString
        }
        
        return .pickerExpandable(mainText: field.title, detailText: detailText, picker: picker)
    }
}

private extension SettingsModeFollower.Field {
    var title: String {
        switch self {
        case .service: return "settings_mode_settings_service".localized
        case .nightscoutUrl: return "settings_mode_settings_nightscout_url".localized
        case .offset: return "settings_mode_settings_offset".localized
        case .apiSecret: return "settings_mode_settings_api_secret".localized
        }
    }
}

//
//  SettingsAlertSingleTypePresenter.swift
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

protocol SettingsAlertSingleTypePresentationLogic {
    func presentLoad(response: SettingsAlertSingleType.Load.Response)
}

final class SettingsAlertSingleTypePresenter: SettingsAlertSingleTypePresentationLogic {
    weak var viewController: SettingsAlertSingleTypeDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsAlertSingleType.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(
            sections: [
                createSettingsSection(response: response),
                createEventsSection(response: response)
            ]
        )
        
        let viewModel = SettingsAlertSingleType.Load.ViewModel(
            animated: response.animated,
            title: response.configuration.eventType.title,
            tableViewModel: tableViewModel
        )
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    private func createSettingsSection(response: SettingsAlertSingleType.Load.Response) -> BaseSettings.Section {
        let config = response.configuration
        
        let cells: [BaseSettings.Cell] = [
            createRightSwitchCell(
                .overrideDefault,
                isSwitchOn: config.isEnabled,
                switchValueChangedHandler: response.switchValueChangedHandler
            )
        ]
        
        return .normal(cells: cells, header: "settings_alert_single_type_setting_header".localized, footer: nil)
    }
    
    private func createEventsSection(response: SettingsAlertSingleType.Load.Response) -> BaseSettings.Section {
        let config = response.configuration
        var cells: [BaseSettings.Cell] = []
        
        if config.isEnabled {
            cells.append(contentsOf: createCellsForActiveConfig(config, response: response))
        }
        
        cells.append(
            createRightSwitchCell(
                .entireDay,
                isSwitchOn: config.isEntireDay,
                switchValueChangedHandler: response.switchValueChangedHandler
            )
        )
        
        if !config.isEntireDay {
            cells.append(contentsOf: createCellsForEntireDayConfig(config, response: response))
        }
        
        if config.eventType.requiresGlucoseThreshold {
            let high = GlucoseUnit.convertFromDefault(Double(config.highThreshold))
            let low = GlucoseUnit.convertFromDefault(Double(config.lowThreshold))
            let highTresholdString = String(format: "%.1f", high)
            let lowTresholdString = String(format: "%.1f", low)
            cells.append(
                contentsOf: [
                    createUnitsPickerView(
                        .highTreshold,
                        detailText: highTresholdString,
                        valueChangeHandler: response.pickerViewValueChangedHandler
                    ),
                    createUnitsPickerView(
                        .lowTreshold,
                        detailText: lowTresholdString,
                        valueChangeHandler: response.pickerViewValueChangedHandler
                    )
                ]
            )
        }
        
        return .normal(cells: cells, header: "settings_alert_single_type_events_header".localized, footer: nil)
    }
    
    private func createCellsForActiveConfig(
        _ config: AlertConfiguration,
        response: SettingsAlertSingleType.Load.Response) -> [BaseSettings.Cell] {
        var cells: [BaseSettings.Cell] = []
        
        cells.append(
            contentsOf: [
                createTextInputViewCell(
                    .name,
                    detailText: config.name,
                    placeholder: config.eventType.title,
                    editingChangedHandler: response.textEditingChangedHandler
                ),
                createRightSwitchCell(
                    .snoozeFromNotification,
                    isSwitchOn: config.snoozeFromNotification,
                    switchValueChangedHandler: response.switchValueChangedHandler
                ),
                createCountDownPickerView(
                    .defaultSnooze,
                    detail: config.defaultSnooze,
                    valueChangeHandler: response.timePickerValueChangedHandler
                ),
                createRightSwitchCell(
                    .repeat,
                    isSwitchOn: config.repeat,
                    switchValueChangedHandler: response.switchValueChangedHandler
                ),
                createDisclosureCell(
                    .sound,
                    selectionHandler: response.selectionHandler
                ),
                createRightSwitchCell(
                    .vibrate,
                    isSwitchOn: config.isVibrating,
                    switchValueChangedHandler: response.switchValueChangedHandler
                )
            ]
        )
        
        return cells
    }
    
    private func createCellsForEntireDayConfig(
        _ config: AlertConfiguration,
        response: SettingsAlertSingleType.Load.Response) -> [BaseSettings.Cell] {
        var cells: [BaseSettings.Cell] = []
        
        let startTimeDate = Date(timeIntervalSince1970: config.startTime)
        let endTimeDate = Date(timeIntervalSince1970: config.endTime)
        let startTimeString = DateFormatter.localizedString(
            from: startTimeDate,
            dateStyle: .none,
            timeStyle: .short
        )
        let endTimeString = DateFormatter.localizedString(
            from: endTimeDate,
            dateStyle: .none,
            timeStyle: .short
        )
        
        cells.append(
            contentsOf: [
                createTimePickerView(
                    .startTime,
                    date: startTimeDate,
                    detailText: startTimeString,
                    valueChangeHandler: response.timePickerValueChangedHandler
                ),
                createTimePickerView(
                    .endTime,
                    date: endTimeDate,
                    detailText: endTimeString,
                    valueChangeHandler: response.timePickerValueChangedHandler
                )
            ]
        )
        
        return cells
    }
    
    private func createTextInputViewCell(
        _ field: SettingsAlertSingleType.Field,
        detailText: String?,
        placeholder: String?,
        editingChangedHandler: @escaping (String?) -> Void) -> BaseSettings.Cell {
        return .textInput(mainText: field.title, detailText: detailText, placeholder: placeholder) { string in
            editingChangedHandler(string)
        }
    }
    
    private func createRightSwitchCell(
        _ field: SettingsAlertSingleType.Field,
        isSwitchOn: Bool,
        switchValueChangedHandler: @escaping (SettingsAlertSingleType.Field, Bool) -> Void) -> BaseSettings.Cell {
        return .rightSwitch(text: field.title, isSwitchOn: isSwitchOn) { value in
            switchValueChangedHandler(field, value)
        }
    }
    
    private func createCountDownPickerView(
        _ field: SettingsAlertSingleType.Field,
        detail: TimeInterval?,
        valueChangeHandler: @escaping (SettingsAlertSingleType.Field, TimeInterval) -> Void) -> BaseSettings.Cell {
        var detailText = "\(Int((detail ?? 0.0) / TimeInterval.secondsPerMinute)) "
        detailText += "settings_alert_single_type_minutes".localized
        
        let picker = CustomPickerView(mode: .countDown)
        
        if let detail = detail {
            let hour = Int(detail / TimeInterval.secondsPerHour)
            var minutes = (detail - (TimeInterval(hour) * TimeInterval.secondsPerHour))
            minutes /= TimeInterval.secondsPerMinute
            
            picker.selectRow(hour, inComponent: 0, animated: false)
            picker.selectRow(Int(minutes), inComponent: 2, animated: false)
        }
        
        picker.formatValues = { strings in
            guard strings.count > 3 else { return "" }
            
            let hourString = strings[0]
            let minuteString = strings[2]
            
            guard let hour = Double(hourString), let minute = Double(minuteString) else { return "" }
            
            let time = minute * TimeInterval.secondsPerMinute + hour * TimeInterval.secondsPerHour
            
            valueChangeHandler(field, time)
            
            return "\(Int(time / TimeInterval.secondsPerMinute)) " + "settings_alert_single_type_minutes".localized
        }
        
        return .pickerExpandable(mainText: field.title, detailText: detailText, picker: picker)
    }
    
    private func createTimePickerView(
        _ field: SettingsAlertSingleType.Field,
        date: Date?,
        detailText: String?,
        valueChangeHandler: @escaping (SettingsAlertSingleType.Field, TimeInterval) -> Void) -> BaseSettings.Cell {
        let picker = CustomDatePicker()
        
        picker.datePickerMode = .time
        
        if let date = date {
            picker.date = date
        }
        
        picker.formatDate = { date in
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            guard let hour = components.hour,
                let minutes = components.minute else { return " " }
            
            var time = TimeInterval(hour) * TimeInterval.secondsPerHour
            time += TimeInterval(minutes) * TimeInterval.secondsPerMinute
            time -= TimeInterval(TimeZone.current.secondsFromGMT())
            
            valueChangeHandler(field, time)
            
            return DateFormatter.localizedString(
                from: date,
                dateStyle: .none,
                timeStyle: .short
            )
        }
        
        return .pickerExpandable(mainText: field.title, detailText: detailText, picker: picker)
    }
    
    private func createUnitsPickerView(
        _ field: SettingsAlertSingleType.Field,
        detailText: String?,
        valueChangeHandler: @escaping (SettingsAlertSingleType.Field, Double) -> Void) -> BaseSettings.Cell {
        let range = User.current.settings.unit.minMax
        let step = User.current.settings.unit.pickerStep
        let array = Array(stride(from: range.lowerBound, to: range.upperBound + step, by: step))
        let strings = array.map { String(format: "%.1f", $0) }
        
        let picker = CustomPickerView(data: [strings])
        
        let tolerance = step / 2
        picker.formatValues = { strings in
            if let value = Double(strings[0]) {
                valueChangeHandler(field, value)
            }
            
            return strings[0]
        }
        
        let index = array.firstIndex(
            where: { val in
                guard let text = detailText, let num = Double(text) else { return false }
                return fabs(val - num) < tolerance
            }
        )
        
        picker.selectRow(index ?? 0, inComponent: 0, animated: false)
        
        return .pickerExpandable(mainText: field.title, detailText: detailText, picker: picker)
    }
    
    private func createDisclosureCell(
        _ field: SettingsAlertSingleType.Field,
        selectionHandler: @escaping () -> Void) -> BaseSettings.Cell {
        return .disclosure(mainText: field.title, detailText: nil) {
            selectionHandler()
        }
    }
}

private extension SettingsAlertSingleType.Field {
    var title: String {
        switch self {
        case .overrideDefault: return "settings_alert_single_type_override_default".localized
        case .name: return "settings_alert_single_type_name".localized
        case .snoozeFromNotification: return "settings_alert_single_type_snooze_from_notification".localized
        case .defaultSnooze: return "settings_alert_single_type_snooze".localized
        case .repeat: return "settings_alert_single_type_repeat".localized
        case .sound: return "settings_alert_single_type_sound".localized
        case .vibrate: return "settings_alert_single_type_vibrate".localized
        case .entireDay: return "settings_alert_single_type_entire_day".localized
        case .startTime: return "settings_alert_single_type_start_time".localized
        case .endTime: return "settings_alert_single_type_end_time".localized
        case .highTreshold: return "settings_alert_single_type_high_treshold".localized
        case .lowTreshold: return "settings_alert_single_type_low_treshold".localized
        }
    }
}

private extension AlertEventType {
    var title: String {
        switch self {
        case .default: return "settings_alert_single_type_event_type_title_default".localized
        case .fastRise: return "settings_alert_single_type_event_type_title_fast_rise".localized
        case .urgentHigh: return "settings_alert_single_type_event_type_title_urgent_high".localized
        case .high: return "settings_alert_single_type_event_type_title_high".localized
        case .fastDrop: return "settings_alert_single_type_event_type_title_fast_drop".localized
        case .low: return "settings_alert_single_type_event_type_title_low".localized
        case .urgentLow: return "settings_alert_single_type_event_type_title_urgent_low".localized
        case .missedReadings: return "settings_alert_single_type_event_type_title_missed_readings".localized
        case .phoneMuted: return "settings_alert_single_type_event_type_title_phone_muted".localized
        case .calibrationRequest: return "settings_alert_single_type_event_title_calibration_request".localized
        case .initialCalibrationRequest: return "settings_alert_single_type_event_title_initial_calibration".localized
        case .pairingRequest: return "settings_alert_single_type_event_title_pairing_request".localized
        }
    }
}

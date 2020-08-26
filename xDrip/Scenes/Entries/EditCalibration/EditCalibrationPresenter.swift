//
//  EditCalibrationPresenter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol EditCalibrationPresentationLogic {
    func presentUpdateData(response: EditCalibration.UpdateData.Response)
}

final class EditCalibrationPresenter: EditCalibrationPresentationLogic {
    weak var viewController: EditCalibrationDisplayLogic?
    
    // MARK: Do something
    
    func presentUpdateData(response: EditCalibration.UpdateData.Response) {
        let sections: [BaseSettings.Section] = [
            createSection(.firstInput, response: response)
        ]
        
        let tableViewModel = BaseSettings.ViewModel(sections: sections)
        let viewModel = EditCalibration.UpdateData.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayUpdateData(viewModel: viewModel)
    }
    
    private func createSection(
        _ field: EditCalibration.Field,
        response: EditCalibration.UpdateData.Response
    ) -> BaseSettings.Section {
        var cells: [BaseSettings.Cell] = [
            createGlucosePickerCell(field, glucoseValueChangedPicker: response.glucosePickerValueChanged),
            createDatePickerCell(field, response: response)
        ]
        
        if !response.hasInitialCalibrations {
            let cell = createGlucosePickerCell(
                .secondInput,
                glucoseValueChangedPicker: response.glucosePickerValueChanged
            )
            cells.insert(cell, at: 1)
        }
        
        let header = "edit_calibration_single_section_header".localized
        let footer: String?
        
        if response.hasInitialCalibrations {
            footer = "edit_calibration_single_section_footer".localized
        } else {
            footer = "edit_calibration_second_section_footer".localized
        }
        
        return .normal(
            cells: cells,
            header: header,
            footer: footer)
    }
    
    private func createDatePickerCell(
        _ field: EditCalibration.Field,
        response: EditCalibration.UpdateData.Response
    ) -> BaseSettings.Cell {
        let picker = CustomDatePicker()
        picker.datePickerMode = .dateAndTime
        
        if let sensorStartDate = CGMDevice.current.sensorStartDate {
            picker.minimumDate = max(sensorStartDate, Date() - .secondsPerHour)
        } else {
            picker.minimumDate = Date() - .secondsPerHour
        }
        picker.maximumDate = Date()
        
        if !response.hasInitialCalibrations {
            let date1 = response.date1
            let date2 = response.date2
            
            if field == .firstInput {
                picker.date = date1
                picker.maximumDate = date2
                if date1 == date2 {
                    picker.date = date1 - .secondsPerMinute
                    response.datePickerValueChanged(field, picker.date)
                }
            } else {
                picker.date = date2
            }
        }
        
        picker.formatDate = { date in
            response.datePickerValueChanged(field, date)
            return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        }
        
        let formattedDate = DateFormatter.localizedString(from: picker.date, dateStyle: .short, timeStyle: .short)
        
        return .pickerExpandable(
            mainText: "edit_calibration_date_picker_title".localized,
            detailText: formattedDate,
            picker: picker
        )
    }
    
    private func createGlucosePickerCell(
        _ field: EditCalibration.Field,
        glucoseValueChangedPicker: @escaping (EditCalibration.Field, String?) -> Void
    ) -> BaseSettings.Cell {
        let unit = User.current.settings.unit
        let range = unit.minMax
        let step = unit.pickerStep
        let array = Array(stride(from: range.lowerBound, to: range.upperBound + step, by: step))
        let strings = array.map { String(format: "%.1f", $0) }

        let picker = CustomPickerView(data: [strings, [unit.title]])

        picker.formatValues = { strings in
           glucoseValueChangedPicker(field, strings[0])
           
           return strings[0] + " " + strings[1]
        }
        
        let detail = "0.0 " + unit.title
        
        let title: String
        if field == .firstInput {
            title = "edit_calibration_value_picker_title".localized
        } else {
            title = "edit_calibration_value_picker_title".localized + " #2"
        }
        
        return .pickerExpandable(
            mainText: title,
            detailText: detail,
            picker: picker
        )
    }
}

private extension GlucoseUnit {
    var title: String {
        switch self {
        case .mgDl: return "settings_units_mgdl".localized
        case .mmolL: return "settings_units_mmolL".localized
        }
    }
}

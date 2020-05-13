//
//  EditTrainingPresenter.swift
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

protocol EditTrainingPresentationLogic {
    func presentLoad(response: EditTraining.Load.Response)
}

final class EditTrainingPresenter: EditTrainingPresentationLogic {
    weak var viewController: EditTrainingDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: EditTraining.Load.Response) {
        let sectionViewModel = createSectionViewModel(response: response)
        viewController?.displayLoad(viewModel: sectionViewModel)
    }
    
    private func createSectionViewModel(response: EditTraining.Load.Response) -> EditTraining.Load.ViewModel {
        let localEntry =  response.localEntry
        
        let cells: [EditTraining.PickerExpandableCell] = [
            createDurationPickerExpandableCell(duration: localEntry[.duration], selectionHandler: response.selectionHandler),
            createIntensityPickerExpandableCell(intensity: localEntry[.intensity], selectionHandler: response.selectionHandler),
            createDatePickerExpandableCell(date: localEntry[.dateTime], selectionHandler: response.selectionHandler)
        ]
        
        return EditTraining.Load.ViewModel(title: "edit_training_title".localized, headerTitle: "edit_training_section_title".localized, cells: cells)
    }
    
    private func createDurationPickerExpandableCell(
        duration: AnyObject?,
        selectionHandler: @escaping (EditTraining.Field, AnyObject) -> Void) -> EditTraining.PickerExpandableCell {
        
        var detailText = ""
        let field = EditTraining.Field.duration
        
        let hours = stride(from: 0, to: 24, by: 1).map { String($0) }
        let mins = stride(from: 0, to: 60, by: 1).map { String($0) }
        
        let data = [
            hours,
            ["hours"],
            mins,
            ["min"]
        ]
        
        let picker = EditTrainingCustomPicker(data: data)
        
        if let duration = duration as? TimeInterval {
            let hours = Int(duration / TimeInterval.secondsPerHour)
            let mins = Int((duration - Double(hours) * TimeInterval.secondsPerHour) / TimeInterval.secondsPerMinute)
            
            picker.selectRow(hours, inComponent: 0, animated: false)
            picker.selectRow(mins, inComponent: 2, animated: false)
            
            detailText = String(format: "%.0f m", duration / TimeInterval.secondsPerMinute)
        }
        
        picker.formatValues = { values in
            guard let hour = Double(values[0]), let min = Double(values[2]) else { return "" }
            
            var totalSec = hour * TimeInterval.secondsPerHour + min * TimeInterval.secondsPerMinute
            
            if totalSec < TimeInterval.secondsPerMinute {
                totalSec = TimeInterval.secondsPerMinute
                picker.selectRow(1, inComponent: 2, animated: true)
            }
            
            selectionHandler(field, totalSec as AnyObject)
            
            let totalMins = totalSec / TimeInterval.secondsPerMinute
            
            return String(format: "%.0f m", totalMins)
        }
        
        return EditTraining.PickerExpandableCell(field: field,
                                                 mainText: field.localizedTitle,
                                                 detailText: detailText,
                                                 picker: picker)
    }
    
    private func createIntensityPickerExpandableCell(
        intensity: AnyObject?,
        selectionHandler: @escaping (EditTraining.Field, AnyObject) -> Void) -> EditTraining.PickerExpandableCell {
        
        var detailText = ""
        let field = EditTraining.Field.intensity
        
        let data = [[
            TrainingIntensity.low.localizedTitle,
            TrainingIntensity.normal.localizedTitle,
            TrainingIntensity.high.localizedTitle
        ]]
        
        let picker = EditTrainingCustomPicker(data: data)
        
        if let intensity = intensity as? TrainingIntensity, let index = data[0].firstIndex(of: intensity.localizedTitle) {
            detailText = intensity.localizedTitle
            picker.selectRow(index, inComponent: 0, animated: false)
        }
        
        picker.formatValues = { values in
            guard let intensityString = values.first else { return "" }
            
            let trainings = [
                TrainingIntensity.low,
                TrainingIntensity.normal,
                TrainingIntensity.high
            ]
            
            if let intensity = trainings.first(where: { $0.localizedTitle == intensityString }) {
                selectionHandler(field, intensity as AnyObject)
            }
            return intensityString
        }
        
        return EditTraining.PickerExpandableCell(field: field,
                                                 mainText: field.localizedTitle,
                                                 detailText: detailText,
                                                 picker: picker)
    }
    
    private func createDatePickerExpandableCell(
        date: AnyObject?,
        selectionHandler: @escaping (EditTraining.Field, AnyObject) -> Void) -> EditTraining.PickerExpandableCell {
        
        var detailText = ""
        let field = EditTraining.Field.dateTime
        
        let picker = EditTrainingCustomDatePicker()
        
        if let date = date as? Date {
            detailText = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
            picker.setDate(date, animated: false)
        }
        
        picker.formatDate = { date in
            selectionHandler(field, date as AnyObject)
            return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        }
        
        return EditTraining.PickerExpandableCell(field: field,
                                                 mainText: field.localizedTitle,
                                                 detailText: detailText,
                                                 picker: picker)
    }
}

private extension EditTraining.Field {
    var localizedTitle: String {
        switch self {
        case .duration: return "edit_training_cell_duration".localized
        case .intensity: return "edit_training_cell_intensity".localized
        case .dateTime: return "edit_training_cell_dateTime".localized
        }
    }
}

private extension TrainingIntensity {
    var localizedTitle: String {
        switch self {
        case .low: return "edit_training_intensity_low".localized
        case .normal: return "edit_training_intensity_normal".localized
        case .high: return "edit_training_intensity_high".localized
        }
    }
}

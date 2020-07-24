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
        let viewModel = EditTraining.Load.ViewModel(
            tableViewModel: BaseSettings.ViewModel(
                sections: [createEnterValuesSection(response: response)]
            )
        )
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    private func createEnterValuesSection(response: EditTraining.Load.Response) -> BaseSettings.Section {
        let cells: [BaseSettings.Cell] = [
            createDurationPickerCell(
                duration: response.trainingEntry?.duration,
                durationChangedHandler: response.timeIntervalChangedHandler
            ),
            createIntensityPickerCell(
                intensity: response.trainingEntry?.intensity,
                intensityChangedHandler: response.trainingIntensityChangedHandler
            ),
            createDatePickerCell(
                date: response.trainingEntry?.entryDate,
                dateChangedHandler: response.dateChangedHandler
            )
        ]
        
        return .normal(
            cells: cells,
            header: "edit_training_section_title".localized,
            footer: nil
        )
    }
    
    private func createDurationPickerCell(
        duration: TimeInterval?,
        durationChangedHandler: @escaping (TimeInterval) -> Void
    ) -> BaseSettings.Cell {
        var detail = ""
        let duration = duration ?? TimeInterval.secondsPerMinute
        let picker = CustomPickerView(mode: .countDown)
        
        let hours = Int(duration / TimeInterval.secondsPerHour)
        let mins = Int((duration - Double(hours) * TimeInterval.secondsPerHour) / TimeInterval.secondsPerMinute)
        
        picker.selectRow(hours, inComponent: 0, animated: false)
        picker.selectRow(mins, inComponent: 2, animated: false)
        
        detail = String(format: "%.0f %@", duration / TimeInterval.secondsPerMinute, "edit_training_m".localized)
        
        picker.formatValues = { values in
            guard let hour = Double(values[0]), let min = Double(values[2]) else { return "" }
            
            var totalSec = hour * TimeInterval.secondsPerHour + min * TimeInterval.secondsPerMinute
            
            if totalSec < TimeInterval.secondsPerMinute {
                totalSec = TimeInterval.secondsPerMinute
                picker.selectRow(1, inComponent: 2, animated: true)
            }
            
            durationChangedHandler(totalSec)
            
            let totalMins = totalSec / TimeInterval.secondsPerMinute
            
            return String(format: "%.0f %@", totalMins, "edit_training_m".localized)
        }
        
        return .pickerExpandable(
            mainText: EditTraining.Field.duration.localizedTitle,
            detailText: detail,
            picker: picker
        )
    }
    
    private func createIntensityPickerCell(
        intensity: TrainingIntensity?,
        intensityChangedHandler: @escaping (TrainingIntensity) -> Void
    ) -> BaseSettings.Cell {
        var detail = ""
        let intensity = intensity ?? TrainingIntensity.default
        let data = TrainingIntensity.allCases.map({ $0.localizedTitle })
        
        let picker = CustomPickerView(data: [data])
        
        if let index = data.firstIndex(of: intensity.localizedTitle) {
            detail = intensity.localizedTitle
            picker.selectRow(index, inComponent: 0, animated: false)
        }
        
        picker.formatValues = { values in
            guard let intensityString = values.first else { return "" }
            
            let trainings = TrainingIntensity.allCases
            
            if let intensity = trainings.first(where: { $0.localizedTitle == intensityString }) {
                intensityChangedHandler(intensity)
            }
            return intensityString
        }
        
        return .pickerExpandable(
            mainText: EditTraining.Field.intensity.localizedTitle,
            detailText: detail,
            picker: picker
        )
    }
    
    private func createDatePickerCell(
        date: Date?,
        dateChangedHandler: @escaping (Date) -> Void
    ) -> BaseSettings.Cell {
        let date = date ?? Date()
        
        let picker = CustomDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.date = date
        
        let detail = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        
        picker.formatDate = { date in
            dateChangedHandler(date)
            
            return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        }
        
        return .pickerExpandable(
            mainText: EditTraining.Field.dateTime.localizedTitle,
            detailText: detail,
            picker: picker
        )
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

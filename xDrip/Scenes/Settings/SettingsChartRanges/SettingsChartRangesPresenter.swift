//
//  SettingsChartRangesPresenter.swift
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

protocol SettingsChartRangesPresentationLogic {
    func presentLoad(response: SettingsChartRanges.Load.Response)
}

final class SettingsChartRangesPresenter: SettingsChartRangesPresentationLogic {
    weak var viewController: SettingsChartRangesDisplayLogic?
    
    private lazy var settings: Settings = {
        return User.current.settings ?? Settings()
    }()
    
    // MARK: Do something
    
    func presentLoad(response: SettingsChartRanges.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(
            sections: [
                createNormalSection(response: response),
                createAboveNormalSection(),
                createUrgentSection(response: response)
            ]
        )
        
        let viewModel = SettingsChartRanges.Load.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    private func createNormalSection(response: SettingsChartRanges.Load.Response) -> BaseSettings.Section {
        var highValue = settings.warningLevelValue(for: .high)
        var lowValue = settings.warningLevelValue(for: .low)
        highValue = GlucoseUnit.convertFromDefault(highValue)
        lowValue = GlucoseUnit.convertFromDefault(lowValue)
        
        let cells: [BaseSettings.Cell] = [
            createPickerCell(
                .notHigherLess,
                detailValues: [highValue, lowValue],
                pickerValueChanged: response.pickerValueChanged
            )
        ]
        
        let attrHeader = NSMutableAttributedString()
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "greenOval")
        
        attrHeader.append(NSAttributedString(attachment: textAttachment))
        attrHeader.append(NSAttributedString(string: " "))
        attrHeader.append(
            NSAttributedString(
                string: "settings_range_selection_normal_section_header".localized
            )
        )
        
        return .normal(cells: cells, header: nil, footer: nil, attributedHeader: attrHeader, attributedFooter: nil)
    }
    
    private func createAboveNormalSection() -> BaseSettings.Section {
        let step = settings.unit.pickerStep
        var highValue = settings.warningLevelValue(for: .urgentHigh)
        var lowValue = settings.warningLevelValue(for: .urgentLow)
        highValue = GlucoseUnit.convertFromDefault(highValue) - step
        lowValue = GlucoseUnit.convertFromDefault(lowValue) + step
        
        let detailText = String(format: "%.1f/%.1f", highValue, lowValue)
        let cells: [BaseSettings.Cell] = [
            .info(mainText: "High/Low", detailText: detailText, detailTextColor: nil)
        ]
        
        let attrHeader = NSMutableAttributedString()
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "orangeOval")
        
        attrHeader.append(NSAttributedString(attachment: textAttachment))
        attrHeader.append(NSAttributedString(string: " "))
        attrHeader.append(
            NSAttributedString(
                string: "setttings_range_selection_above_normal_section_header".localized
            )
        )
        
        return .normal(cells: cells, header: nil, footer: nil, attributedHeader: attrHeader, attributedFooter: nil)
    }
    
    private func createUrgentSection(response: SettingsChartRanges.Load.Response) -> BaseSettings.Section {
        var highValue = settings.warningLevelValue(for: .urgentHigh)
        var lowValue = settings.warningLevelValue(for: .urgentLow)
        highValue = GlucoseUnit.convertFromDefault(highValue)
        lowValue = GlucoseUnit.convertFromDefault(lowValue)
        
        let cells: [BaseSettings.Cell] = [
            createPickerCell(
                .urgent,
                detailValues: [highValue, lowValue],
                pickerValueChanged: response.pickerValueChanged
            )
        ]
        
        let attrHeader = NSMutableAttributedString()
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "redOval")
        
        attrHeader.append(NSAttributedString(attachment: textAttachment))
        attrHeader.append(
            NSAttributedString(
                string: "settings_range_selection_urgent_section_header".localized
            )
        )
        
        return .normal(cells: cells, header: nil, footer: nil, attributedHeader: attrHeader, attributedFooter: nil)
    }
    
    private func createPickerCell(
        _ field: SettingsChartRanges.Field,
        detailValues: [Double],
        pickerValueChanged: @escaping (SettingsChartRanges.Field, [Double]) -> Void) -> BaseSettings.Cell {
        let range = settings.unit.minMax
        let step = settings.unit.pickerStep
        var array1 = [Double]()
        var array2 = [Double]()
        
        if field == .notHigherLess {
            array1 = Array(stride(from: range.lowerBound, to: range.upperBound + step - 2 * step, by: step))
            array2 = Array(stride(from: range.lowerBound + 2 * step, to: range.upperBound + step, by: step))
        } else if field == .urgent {
            let minHighRaw = settings.warningLevelValue(for: .high)
            let maxLowRaw = settings.warningLevelValue(for: .low)
            var minHigh = GlucoseUnit.convertFromDefault(minHighRaw)
            var maxLow = GlucoseUnit.convertFromDefault(maxLowRaw)
            
            if settings.unit == .mgDl {
                minHigh = minHigh.rounded(.up)
                maxLow = maxLow.rounded(.down)
            }
            
            array1 = Array(stride(from: minHigh + 2 * step, to: range.upperBound + step, by: step))
            array2 = Array(stride(from: range.lowerBound, to: maxLow + step - 2 * step, by: step))
        }
        
        let column1 = array1.map { String(format: "%.1f", $0) }
        let column2 = array2.map { String(format: "%.1f", $0) }
        
        let data = [column1, column2, [settings.unit.title]]
        
        let picker = CustomPickerView(data: data)
        
        let tolerance = step / 2
        picker.formatValues = { strings in
            guard strings.count > 1 else { return " " }
            
            if let high = array1.first(
                where: { val in
                    guard let num = Double(strings[0]) else { return false }
                    return fabs(val - num) < tolerance
                }
            ), let low = array2.first(
                where: { val in
                    guard let num = Double(strings[1]) else { return false }
                    return fabs(val - num) < tolerance
                }
            ) {
                pickerValueChanged(field, [high, low])
            }
            
            return strings[0] + "/" + strings[1]
        }
        
        let first = array1.firstIndex(where: { fabs($0 - detailValues[0]) < tolerance })
        let second = array2.firstIndex(where: { fabs($0 - detailValues[1]) < tolerance })
        
        picker.selectRow(first ?? 0, inComponent: 0, animated: false)
        picker.selectRow(second ?? 0, inComponent: 1, animated: false)
        
        let detailText = String(format: "%.1f/%.1f", detailValues[0], detailValues[1])
        
        return .pickerExpandable(mainText: field.title, detailText: detailText, picker: picker)
    }
}

private extension SettingsChartRanges.Field {
    var title: String {
        switch self {
        case .notHigherLess: return "settings_range_selection_not_higher_less".localized
        case .highLow: return "settings_range_selection_high_low".localized
        case .urgent: return "settings_range_selection_urgent_high_low".localized
        }
    }
}

private extension GlucoseUnit {
    var title: String {
        switch self {
        case .mgDl: return "settings_range_selection_mgdl".localized
        case .mmolL: return "settings_range_selection_mmolL".localized
        }
    }
}

//
//  SettingsChartPresenter.swift
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

protocol SettingsChartPresentationLogic {
    func presentLoad(response: SettingsChart.Load.Response)
}

final class SettingsChartPresenter: SettingsChartPresentationLogic {
    weak var viewController: SettingsChartDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsChart.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(
            sections: [
                createNormalSection(response: response),
                createSingleSelectionSection(response: response)
            ]
        )
        
        let viewModel = SettingsChart.Load.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    private func createNormalSection(response: SettingsChart.Load.Response) -> BaseSettings.Section {
        let settings = User.current.settings.chart
        
        let cells: [BaseSettings.Cell] = [
            createRightSwitchCell(
                .activeInsulin,
                isSwitchOn: settings?.showActiveInsulin ?? false,
                switchHandler: response.switchValueChangedHandler
            ),
            createRightSwitchCell(
                .activeCarbs,
                isSwitchOn: settings?.showActiveCarbs ?? false,
                switchHandler: response.switchValueChangedHandler
            ),
            createRightSwitchCell(
                .data,
                isSwitchOn: settings?.showData ?? false,
                switchHandler: response.switchValueChangedHandler
            )
        ]
        
        return BaseSettings.Section.normal(
            cells: cells,
            header: nil,
            footer: "settings_chart_switch_section_footer".localized
        )
    }
    
    private func createSingleSelectionSection(response: SettingsChart.Load.Response) -> BaseSettings.Section {
        let settings = User.current.settings.chart
        let cells = ChartSettings.BasalDisplayMode.allCases.map { $0.title }
        
        return BaseSettings.Section.singleSelection(
            cells: cells,
            selectedIndex: settings?.basalDisplayMode.rawValue ?? 0,
            header: "settings_chart_render_section_header".localized,
            footer: "settings_chart_render_section_footer".localized,
            selectionHandler: response.singleSelectionHandler
        )
    }
    
    private func createRightSwitchCell(
        _ field: SettingsChart.Field,
        isSwitchOn: Bool,
        switchHandler: @escaping (SettingsChart.Field, Bool) -> Void) -> BaseSettings.Cell {
        return .rightSwitch(text: field.title, isSwitchOn: isSwitchOn) { value in
            switchHandler(field, value)
        }
    }
}

private extension ChartSettings.BasalDisplayMode {
    var title: String {
        switch self {
        case .onTop: return "settings_chart_basal_display_mode_top".localized
        case .onBottom: return "settings_chart_basal_display_mode_bottom".localized
        case .notShown: return "settings_chart_basal_display_mode_not_shown".localized
        }
    }
}

private extension SettingsChart.Field {
    var title: String {
        switch self {
        case .activeInsulin: return "settings_chart_active_insulin".localized
        case .activeCarbs: return "settings_chart_active_carbs".localized
        case .data: return "settings_chart_data".localized
        }
    }
}

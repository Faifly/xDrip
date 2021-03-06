//
//  SettingsModeMasterPresenter.swift
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

protocol SettingsModeMasterPresentationLogic {
    func presentLoad(response: SettingsModeMaster.Load.Response)
}

final class SettingsModeMasterPresenter: SettingsModeMasterPresentationLogic {
    weak var viewController: SettingsModeMasterDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsModeMaster.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(
            sections: [
                createSection(response: response)
            ]
        )
        
        let viewModel = SettingsModeMaster.Load.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    func createSection(response: SettingsModeMaster.Load.Response) -> BaseSettings.Section {
        let cells: [BaseSettings.Cell] = [
            createDisclosureCell(.sensor, selectionHandler: response.singleSelectionHandler),
            createDisclosureCell(.transmitter, selectionHandler: response.singleSelectionHandler)
        ]
        
        return .normal(cells: cells, header: nil, footer: nil)
    }
    
    func createDisclosureCell(
        _ field: SettingsModeMaster.Field,
        selectionHandler: @escaping (SettingsModeMaster.Field) -> Void) -> BaseSettings.Cell {
        return .disclosure(mainText: field.title, detailText: nil) {
            selectionHandler(field)
        }
    }
}

private extension SettingsModeMaster.Field {
    var title: String {
        switch self {
        case .sensor: return "settings_mode_settings_sensor".localized
        case .transmitter: return "settings_mode_settings_transmitter".localized
        }
    }
}

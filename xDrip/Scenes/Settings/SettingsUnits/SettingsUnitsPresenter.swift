//
//  SettingsUnitsPresenter.swift
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

protocol SettingsUnitsPresentationLogic {
    func presentLoad(response: SettingsUnits.Load.Response)
}

final class SettingsUnitsPresenter: SettingsUnitsPresentationLogic {
    weak var viewController: SettingsUnitsDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsUnits.Load.Response) {
        let tableViewModel = BaseSettings.ViewModel(sections: [
            createUnitsSection(response: response)
        ])
        
        let viewModel = SettingsUnits.Load.ViewModel(tableViewModel: tableViewModel)
        viewController?.displayLoad(viewModel: viewModel)
    }
    
    private func createUnitsSection(response: SettingsUnits.Load.Response) -> BaseSettings.Section {
        let titles = GlucoseUnit.allCases.map { $0.title }
        let index = GlucoseUnit.allCases.firstIndex(of: response.currentSelectedUnit) ?? 0
        
        return BaseSettings.Section.singleSelection(cells: titles, selectedIndex: index, header: nil, footer: nil, selectionHandler: response.selectionHandler)
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

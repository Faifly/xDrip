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
        let viewModel = SettingsUnits.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
}

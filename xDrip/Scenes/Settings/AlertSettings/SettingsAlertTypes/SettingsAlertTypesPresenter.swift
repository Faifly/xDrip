//
//  SettingsAlertTypesPresenter.swift
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

protocol SettingsAlertTypesPresentationLogic {
    func presentLoad(response: SettingsAlertTypes.Load.Response)
}

final class SettingsAlertTypesPresenter: SettingsAlertTypesPresentationLogic {
    weak var viewController: SettingsAlertTypesDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsAlertTypes.Load.Response) {
        let viewModel = SettingsAlertTypes.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
}

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
        let viewModel = SettingsAlertSingleType.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
}

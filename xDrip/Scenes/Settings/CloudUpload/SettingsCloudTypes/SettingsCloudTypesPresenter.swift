//
//  SettingsCloudTypesPresenter.swift
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

protocol SettingsCloudTypesPresentationLogic {
    func presentLoad(response: SettingsCloudTypes.Load.Response)
}

final class SettingsCloudTypesPresenter: SettingsCloudTypesPresentationLogic {
    weak var viewController: SettingsCloudTypesDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: SettingsCloudTypes.Load.Response) {
        let viewModel = SettingsCloudTypes.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
}
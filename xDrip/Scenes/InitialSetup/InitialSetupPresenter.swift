//
//  InitialSetupPresenter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol InitialSetupPresentationLogic {
    func presentLoad(response: InitialSetup.Load.Response)
}

final class InitialSetupPresenter: InitialSetupPresentationLogic {
    weak var viewController: InitialSetupDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: InitialSetup.Load.Response) {
        let viewModel = InitialSetup.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
}
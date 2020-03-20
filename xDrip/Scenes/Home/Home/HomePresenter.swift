//
//  HomePresenter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol HomePresentationLogic {
    func presentLoad(response: Home.Load.Response)
}

final class HomePresenter: HomePresentationLogic {
    weak var viewController: HomeDisplayLogic?
    
    // MARK: Do something
    
    func presentLoad(response: Home.Load.Response) {
        let viewModel = Home.Load.ViewModel()
        viewController?.displayLoad(viewModel: viewModel)
    }
}
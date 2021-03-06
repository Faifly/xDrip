//
//  SettingsAlertSingleTypeViewController.swift
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

protocol SettingsAlertSingleTypeDisplayLogic: AnyObject {
    func displayLoad(viewModel: SettingsAlertSingleType.Load.ViewModel)
}

class SettingsAlertSingleTypeViewController: BaseSettingsViewController, SettingsAlertSingleTypeDisplayLogic {
    var interactor: SettingsAlertSingleTypeBusinessLogic?
    var router: SettingsAlertSingleTypeDataPassing?
    
    // MARK: Object lifecycle
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use regular init")
    }
    
    required init() {
        super.init()
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = SettingsAlertSingleTypeInteractor()
        let presenter = SettingsAlertSingleTypePresenter()
        let router = SettingsAlertSingleTypeRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = SettingsAlertSingleType.Load.Request(animated: false)
        interactor?.doLoad(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsAlertSingleType.Load.ViewModel) {
        update(with: viewModel.tableViewModel, animated: viewModel.animated)
        title = viewModel.title
    }
}

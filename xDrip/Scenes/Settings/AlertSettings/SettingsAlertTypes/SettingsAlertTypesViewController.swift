//
//  SettingsAlertTypesViewController.swift
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

protocol SettingsAlertTypesDisplayLogic: AnyObject {
    func displayLoad(viewModel: SettingsAlertTypes.Load.ViewModel)
}

class SettingsAlertTypesViewController: BaseSettingsViewController, SettingsAlertTypesDisplayLogic {
    var interactor: SettingsAlertTypesBusinessLogic?
    var router: SettingsAlertTypesDataPassing?
    
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
        let interactor = SettingsAlertTypesInteractor()
        let presenter = SettingsAlertTypesPresenter()
        let router = SettingsAlertTypesRouter()
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
        let request = SettingsAlertTypes.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsAlertTypes.Load.ViewModel) {
    }
}

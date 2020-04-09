//
//  SettingsModeMasterViewController.swift
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

protocol SettingsModeMasterDisplayLogic: class {
    func displayLoad(viewModel: SettingsModeMaster.Load.ViewModel)
}

class SettingsModeMasterViewController: BaseSettingsViewController, SettingsModeMasterDisplayLogic {
    var interactor: SettingsModeMasterBusinessLogic?
    
    // MARK: Object lifecycle
    
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
        let interactor = SettingsModeMasterInteractor()
        let presenter = SettingsModeMasterPresenter()
        let router = SettingsModeMasterRouter()
        viewController.interactor = interactor
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
        let request = SettingsModeMaster.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsModeMaster.Load.ViewModel) {
        
    }
}

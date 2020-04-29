//
//  SettingsAlertSoundViewController.swift
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

protocol SettingsAlertSoundDisplayLogic: class {
    func displayLoad(viewModel: SettingsAlertSound.Load.ViewModel)
}

class SettingsAlertSoundViewController: BaseSettingsViewController, SettingsAlertSoundDisplayLogic {
    var interactor: SettingsAlertSoundBusinessLogic?
    
    // MARK: Object lifecycle
    
    required init() {
        fatalError("Use init(configuration:)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(configuration:)t")
    }
    
    init(configuration: AlertConfiguration) {
        self.configuration = configuration
        
        super.init()
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = SettingsAlertSoundInteractor()
        let presenter = SettingsAlertSoundPresenter()
        let router = SettingsAlertSoundRouter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    
    var configuration: AlertConfiguration
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = SettingsAlertSound.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsAlertSound.Load.ViewModel) {
        
    }
}

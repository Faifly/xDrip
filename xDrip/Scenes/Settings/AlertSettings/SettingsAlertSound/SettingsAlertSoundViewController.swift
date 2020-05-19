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

protocol SettingsAlertSoundDisplayLogic: AnyObject {
    func displayLoad(viewModel: SettingsAlertSound.Load.ViewModel)
}

class SettingsAlertSoundViewController: BaseSettingsViewController, SettingsAlertSoundDisplayLogic {
    var interactor: SettingsAlertSoundBusinessLogic?
    var router: SettingsAlertSoundDataPassing?
    
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
        let interactor = SettingsAlertSoundInteractor()
        let presenter = SettingsAlertSoundPresenter()
        let router = SettingsAlertSoundRouter()
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
        setupUI()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = SettingsAlertSound.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsAlertSound.Load.ViewModel) {
        update(with: viewModel.tableViewModel)
    }
    
    private func setupUI() {
        title = "settings_alert_sound_title".localized
    }
}

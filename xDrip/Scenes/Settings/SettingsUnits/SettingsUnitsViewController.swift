//
//  SettingsUnitsViewController.swift
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

protocol SettingsUnitsDisplayLogic: class {
    func displayLoad(viewModel: SettingsUnits.Load.ViewModel)
    func displaySelect(viewModel: SettingsUnits.Select.ViewModel)
}

class SettingsUnitsViewController: BaseSettingsViewController, SettingsUnitsDisplayLogic {
    var interactor: SettingsUnitsBusinessLogic?
    
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
        let interactor = SettingsUnitsInteractor()
        let presenter = SettingsUnitsPresenter()
        let router = SettingsUnitsRouter()
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
        setupUI()
        
        let request = SettingsUnits.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    private func setupUI() {
        title = "Units"
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsUnits.Load.ViewModel) {
        update(with: viewModel.tableViewModel)
    }
    
    func displaySelect(viewModel: SettingsUnits.Select.ViewModel) {
        update(with: viewModel.tableViewModel, animated: true)
    }
}

//
//  SettingsModeFollowerViewController.swift
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

protocol SettingsModeFollowerDisplayLogic: AnyObject {
    func displayLoad(viewModel: SettingsModeFollower.Load.ViewModel)
    func displayUpdate(viewModel: SettingsModeFollower.Update.ViewModel)
}

class SettingsModeFollowerViewController: BaseSettingsViewController, SettingsModeFollowerDisplayLogic {
    var interactor: SettingsModeFollowerBusinessLogic?
    var router: SettingsModeFollowerDataPassing?
    
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
        let interactor = SettingsModeFollowerInteractor()
        let presenter = SettingsModeFollowerPresenter()
        let router = SettingsModeFollowerRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    private lazy var loginBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(
           title: "settings_mode_settings_login_button".localized,
           style: .done,
           target: self,
           action: #selector(onLogin)
        )
        
        return button
    }()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showLoginButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        parent?.parent?.navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = SettingsModeFollower.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    private func showLoginButton() {
        parent?.parent?.navigationItem.rightBarButtonItem = loginBarButtonItem
    }
    
    @objc private func onLogin() {
        let request = SettingsModeFollower.Login.Request()
        interactor?.doLogin(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsModeFollower.Load.ViewModel) {
    }
    
    func displayUpdate(viewModel: SettingsModeFollower.Update.ViewModel) {
        update(with: viewModel.tableViewModel)
        
        switch viewModel.authButtonMode {
        case .login:
            loginBarButtonItem.title = "settings_mode_settings_login_button".localized
        case .logout:
            loginBarButtonItem.title = "settings_mode_settings_logout_button".localized
        }
    }
}

//
//  InitialSetupNightscoutViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 26.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupNightscoutViewController: InitialSetupAbstractStepSettingsViewController {
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSave))
        button.isEnabled = false
        return button
    }()
    
    private var baseURL: String?
    private var apiSecret: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_nightscout_screen_title".localized
        setupTable()
        setupSaveButton()
    }
    
    private func setupTable() {
        let cells: [BaseSettings.Cell] = [
            .textInput(
                mainText: "settings_nightscout_cloud_configuration_base_url_title".localized,
                detailText: nil,
                textFieldText: nil,
                placeholder: "settings_nightscout_cloud_configuration_base_url_placeholder".localized,
                textFieldConfigurator: { textField in
                    textField.keyboardType = .URL
                    textField.autocapitalizationType = .none
                    textField.autocorrectionType = .no
                    textField.textContentType = .URL
                }, textChangedHandler: { [weak self] text in
                    self?.baseURL = text
                }
            ),
            .textInput(
                mainText: "settings_nightscout_cloud_configuration_api_secret_title".localized,
                detailText: nil,
                textFieldText: nil,
                placeholder: "settings_nightscout_cloud_configuration_api_secret_placeholder".localized,
                textFieldConfigurator: { textField in
                    textField.keyboardType = .default
                    textField.autocapitalizationType = .none
                    textField.autocorrectionType = .no
                    textField.textContentType = .URL
                }, textChangedHandler: { [weak self] text in
                    self?.apiSecret = text
                }
            ),
            .button(
                title: "settings_nightscout_cloud_configuration_api_test_button".localized,
                color: .customBlue,
                handler: { [weak self] in
                    self?.onTestConnection()
                }
            )
        ]
        
        let footer: String
        switch User.current.settings.deviceMode {
        case .follower: footer = "settings_mode_settings_follower_section_footer".localized
        case .main: footer = "settings_nightscout_cloud_configuration_credentials_section_footer".localized
        }
        
        let section = BaseSettings.Section.normal(
            cells: cells,
            header: nil,
            footer: footer
        )
        let viewModel = BaseSettings.ViewModel(sections: [section])
        update(with: viewModel)
    }
    
    private func setupSaveButton() {
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func onSave() {
        let request = InitialSetup.SaveNightscoutCredentials.Request()
        interactor?.doSaveNightscoutConnectionData(request: request)
    }
    
    private func onTestConnection() {
        let popUpController = PopUpViewController()
        present(popUpController, animated: true, completion: nil)
        
        User.current.settings.nightscoutSync?.updateBaseURL(baseURL)
        User.current.settings.nightscoutSync?.updateAPISecret(apiSecret)
        
        let tryAuth = User.current.settings.deviceMode == .main || !String.isEmpty(apiSecret)
        NightscoutConnectionTestWorker().testNightscoutConnection(
            tryAuth: tryAuth) { [weak self, weak popUpController] success, message, image in
                self?.saveButton.isEnabled = success
                popUpController?.presentFinishAlert(message: message, icon: image)
        }
    }
}

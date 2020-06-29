//
//  InitialSetupDeviceModeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupDeviceModeViewController: InitialSetupAbstractStepSettingsViewController {
    private var currentType = UserDeviceMode.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_device_mode_screen_title".localized
        setupTable()
        setupSaveButton()
    }
    
    private func setupTable() {
        let section = BaseSettings.Section.singleSelection(
            cells: ["initial_device_mode_master".localized, "initial_device_mode_follower".localized],
            selectedIndex: 0,
            header: nil,
            footer: "initial_device_mode_section_footer".localized,
            selectionHandler: { [weak self] index in
                switch index {
                case 0: self?.currentType = .main
                case 1: self?.currentType = .follower
                default: fatalError("Invalid index")
                }
            }
        )
        
        let viewModel = BaseSettings.ViewModel(sections: [section])
        update(with: viewModel)
    }
    
    private func setupSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSave))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func onSave() {
        let request = InitialSetup.SelectDeviceMode.Request(deviceMode: currentType)
        interactor?.doSelectDeviceMode(request: request)
    }
}

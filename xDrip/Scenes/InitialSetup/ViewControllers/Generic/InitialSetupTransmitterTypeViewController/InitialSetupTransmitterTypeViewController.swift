//
//  InitialSetupTransmitterTypeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupTransmitterTypeViewController: InitialSetupAbstractStepSettingsViewController {
    private var deviceType = CGMDeviceType.dexcomG6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_transmitter_type_screen_title".localized
        setupTable()
        setupSaveButton()
    }
    
    private func setupTable() {
        let section = BaseSettings.Section.singleSelection(
            cells: ["initial_transmitter_type_dexcom_g6".localized],
            selectedIndex: 0,
            header: nil,
            footer: "initial_transmitter_type_section_footer".localized,
            selectionHandler: { _ in }
        )
        let viewModel = BaseSettings.ViewModel(sections: [section])
        update(with: viewModel)
    }
    
    private func setupSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSave))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func onSave() {
        let request = InitialSetup.SelectDevice.Request(deviceType: deviceType)
        interactor?.doSelectDeviceType(request: request)
    }
}

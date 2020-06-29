//
//  InitialSetupInjectionTypeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupInjectionTypeViewController: InitialSetupAbstractStepSettingsViewController {
    private var currentType = UserInjectionType.pen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_injection_type_screen_title".localized
        setupTable()
        setupSaveButton()
    }
    
    private func setupTable() {
        let section = BaseSettings.Section.singleSelection(
            cells: ["initial_injection_type_pen".localized],
            selectedIndex: 0,
            header: nil,
            footer: "initial_injection_type_section_footer".localized,
            selectionHandler: { [weak self] index in
                switch index {
                case 0: self?.currentType = .pen
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
        let request = InitialSetup.SelectInjectionType.Request(injectionType: currentType)
        interactor?.doSelectInjectionType(request: request)
    }
}

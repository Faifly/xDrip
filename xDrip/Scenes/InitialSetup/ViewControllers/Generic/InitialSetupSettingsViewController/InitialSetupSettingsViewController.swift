//
//  InitialSetupSettingsViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupSettingsViewController: InitialSetupAbstractStepSettingsViewController {
    private var selectedUnit = GlucoseUnit.allCases[0]
    private var alertsEnabled = true
    private var enabledNightscout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_settings_screen_title".localized
        setupTable()
        setupBarButton()
    }
    
    private func setupTable() {
        let unitsSection = BaseSettings.Section.singleSelection(
            cells: GlucoseUnit.allCases.map { $0.label },
            selectedIndex: 0,
            header: "initial_settings_units_section_header".localized,
            footer: "initial_settings_units_section_footer".localized,
            selectionHandler: { [weak self] index in
                self?.selectedUnit = GlucoseUnit.allCases[index]
            }
        )
        
        let alertsSection = BaseSettings.Section.singleSelection(
            cells: ["initial_settings_alerts_enabled".localized, "initial_settings_alerts_disabled".localized],
            selectedIndex: 0,
            header: "initial_settings_alerts_section_header".localized,
            footer: "initial_settings_alerts_section_footer".localized,
            selectionHandler: { [weak self] index in
                self?.alertsEnabled = index == 0
            }
        )
        
        var sections = [unitsSection, alertsSection]
        
        if User.current.settings.deviceMode == .main {
            let uploadSection = BaseSettings.Section.singleSelection(
                cells: ["initial_settings_cloud_none".localized, "initial_settings_cloud_nightscout".localized],
                selectedIndex: 0,
                header: "initial_settings_cloud_section_header".localized,
                footer: "initial_settings_cloud_section_footer".localized,
                selectionHandler: { [weak self] index in
                    self?.enabledNightscout = index == 1
                }
            )
            sections.append(uploadSection)
        }
        
        let viewModel = BaseSettings.ViewModel(sections: sections)
        update(with: viewModel)
    }
    
    private func setupBarButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(onSaveSettings))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func onSaveSettings() {
        let request = InitialSetup.SaveSettings.Request(
            alertsEnabled: alertsEnabled,
            units: selectedUnit,
            nightscoutEnabled: enabledNightscout
        )
        interactor?.doSaveSettings(request: request)
    }
}

//
//  InitialSetupSettingsViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupSettingsViewController: InitialSetupAbstractStepViewController {
    @IBAction private func onSaveSettings() {
        let request = InitialSetup.SaveSettings.Request()
        interactor?.doSaveSettings(request: request)
    }
}

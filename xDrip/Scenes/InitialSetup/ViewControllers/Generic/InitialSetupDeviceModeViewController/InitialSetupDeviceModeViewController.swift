//
//  InitialSetupDeviceModeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupDeviceModeViewController: InitialSetupAbstractStepViewController {
    @IBAction private func onMainTypeSelected() {
        let request = InitialSetup.SelectDeviceMode.Request(deviceMode: .main)
        interactor?.doSelectDeviceMode(request: request)
    }
    
    @IBAction private func onFollowerTypeSelected() {
        let request = InitialSetup.SelectDeviceMode.Request(deviceMode: .follower)
        interactor?.doSelectDeviceMode(request: request)
    }
}

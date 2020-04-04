//
//  InitialSetupTransmitterTypeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupTransmitterTypeViewController: InitialSetupAbstractStepViewController {
    @IBAction private func onDexcomG6Selected() {
        let request = InitialSetup.SelectDevice.Request(deviceType: .dexcomG6)
        interactor?.doSelectDeviceType(request: request)
    }
}

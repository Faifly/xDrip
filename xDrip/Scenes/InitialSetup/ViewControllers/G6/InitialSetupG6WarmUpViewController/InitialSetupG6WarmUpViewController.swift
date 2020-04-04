//
//  InitialSetupG6WarmUpViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupG6WarmUpViewController: InitialSetupAbstractStepViewController {
    @IBAction private func onFinishSetup() {
        let request = InitialSetup.CompleteCustomDeviceStep.Request(moreStepsExpected: false)
        interactor?.doCompleteCustomDeviceStep(request: request)
    }
}

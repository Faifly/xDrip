//
//  InitialSetupG6DeviceIDViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupG6DeviceIDViewController: InitialSetupAbstractStepViewController {
    private let worker = DexcomG6SerialSavingWorker()
    
    @IBOutlet private weak var deviceIDTextField: UITextField!
    
    @IBAction private func onContinueTap() {
        guard worker.validate(deviceIDTextField.text) else {
            showInvalidFormatAlert()
            return
        }
        
        worker.saveID(deviceIDTextField.text)
        
        let request = InitialSetup.CompleteCustomDeviceStep.Request(moreStepsExpected: true)
        interactor?.doCompleteCustomDeviceStep(request: request)
    }
    
    private func showInvalidFormatAlert() {
        UIAlertController.showOKAlert(
            title: "Invalid format",
            message: "Dexcom G6 serial number should contain 6 uppercased characters or digits"
        )
    }
}

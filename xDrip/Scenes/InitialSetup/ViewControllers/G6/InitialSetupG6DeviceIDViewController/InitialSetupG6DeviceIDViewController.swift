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
        let alert = UIAlertController(
            title: "Invalid format",
            message: "Dexcom G6 serial number should contain 6 uppercased characters or digits",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        
        AlertPresenter.shared.presentAlert(alert)
    }
}

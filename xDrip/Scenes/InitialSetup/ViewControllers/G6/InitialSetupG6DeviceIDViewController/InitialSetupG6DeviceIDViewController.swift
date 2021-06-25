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
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "initial_transmitter_id_screen_title".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(onSaveTap)
        )
        
        deviceIDTextField.delegate = self
        
        KeyboardController.shared.subscribe(listener: self) { [weak self] willShow, height in
            guard let self = self else { return }
            if willShow {
                if let height = height {
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.bottomConstraint.constant = height + 10
                    })
                }
            } else {
                self.bottomConstraint.constant = 0
            }
        }
    }
    
    deinit {
        KeyboardController.shared.unsubscribe(listener: self)
    }
    
    @objc private func onSaveTap() {
        guard worker.validate(deviceIDTextField.text) else {
            showInvalidFormatAlert()
            return
        }
        
        worker.saveID(deviceIDTextField.text)
        
        let request = InitialSetup.CompleteCustomDeviceStep.Request(
            moreStepsExpected: true,
            step: InitialSetupG6Step.deviceID
        )
        interactor?.doCompleteCustomDeviceStep(request: request)
    }
    
    @IBAction private func onOpenGuide() {
        guard let url = URL(string: "initial_transmitter_id_guide_link".localized) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func showInvalidFormatAlert() {
        let alert = UIAlertController(
            title: "initial_transmitter_id_invalid_alert_title".localized,
            message: "initial_transmitter_id_invalid_alert_message".localized,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(
            title: "initial_transmitter_id_invalid_alert_button".localized,
            style: .cancel,
            handler: nil
        )
        alert.addAction(confirmAction)
        
        AlertPresenter.shared.presentAlert(alert)
    }
}

extension InitialSetupG6DeviceIDViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//
//  InitialSetupWarningViewController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 12.10.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupWarningViewController: InitialSetupAbstractStepViewController {
    @IBOutlet private weak var understandSwitch: UISwitch!
    @IBOutlet private weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_warning_screen_title".localized
        textView.text = "initial_warning_important_text".localized
        setupSaveButton()
    }
    
    private func setupSaveButton() {
        let agreeButton = UIBarButtonItem(
            title: "initial_warning_agree".localized,
            style: .done,
            target: self,
            action: #selector(onAgree)
        )
        agreeButton.isEnabled = false
        navigationItem.rightBarButtonItem = agreeButton
    }
    
    @objc private func onAgree() {
        let request = InitialSetup.WarningAgreed.Request()
        interactor?.doWarningAgreed(request: request)
    }
    
    @IBAction private func onUnderstand() {
        let state = understandSwitch.isOn
        understandSwitch.setOn(!state, animated: true)
        understandSwitch.sendActions(for: .valueChanged)
    }
    
    @IBAction private func onSwitchToggle(_ sender: UISwitch) {
        navigationItem.rightBarButtonItem?.isEnabled = sender.isOn
    }
}

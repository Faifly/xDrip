//
//  InitialSetupFinishViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 27.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupFinishViewController: InitialSetupAbstractStepViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_finish_screen_title".localized
    }
    
    @IBAction private func onFinishSetup() {
        let request = InitialSetup.FinishSetup.Request()
        interactor?.doFinishSetup(request: request)
    }
}

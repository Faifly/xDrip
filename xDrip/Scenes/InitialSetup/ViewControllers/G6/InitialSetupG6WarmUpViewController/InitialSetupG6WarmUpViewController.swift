//
//  InitialSetupG6WarmUpViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupG6WarmUpViewController: InitialSetupAbstractStepViewController {
    @IBOutlet private weak var infoLabel: UILabel!
    
    private let warmUpWorker = InitialSetupWarmUpWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "initial_warmup_screen_title".localized
        
        if let warmUpLeft = warmUpWorker.timeUntilWarmUpFinished(), let text = infoLabel.text {
            infoLabel.text = text + String(format: "initial_warmup_time_left_text".localized, warmUpLeft)
        }
    }
    
    @IBAction private func onFinishSetup() {
        let request = InitialSetup.CompleteCustomDeviceStep.Request(
            moreStepsExpected: false,
            step: InitialSetupG6Step.warmUp
        )
        interactor?.doCompleteCustomDeviceStep(request: request)
    }
}

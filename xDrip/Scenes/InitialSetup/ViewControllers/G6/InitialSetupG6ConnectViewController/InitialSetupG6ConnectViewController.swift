//
//  InitialSetupG6ConnectViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupG6ConnectViewController: InitialSetupAbstractStepViewController {
    struct ViewModel {
        let firmware: String?
        let batteryA: String?
        let batteryB: String?
        let transmitterTime: String?
    }
    
    required init(connectionWorker: InitialSetupDexcomG6ConnectionWorkerProtocol) {
        worker = connectionWorker
        super.init()
    }
    
    required init() {
        fatalError("Use DI init")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use DI init")
    }
    
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var firmwareLabel: UILabel!
    @IBOutlet private weak var batteryALabel: UILabel!
    @IBOutlet private weak var batteryBLabel: UILabel!
    @IBOutlet private weak var transmitterTimeLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    
    @IBAction private func onContinueTap() {
        let request = InitialSetup.CompleteCustomDeviceStep.Request(moreStepsExpected: true)
        interactor?.doCompleteCustomDeviceStep(request: request)
    }
    
    private let worker: InitialSetupDexcomG6ConnectionWorkerProtocol
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worker.onSuccessfulConnection = { [weak self] viewModel in
            guard let self = self else { return }
            self.update(withViewModel: viewModel)
        }
        worker.startConnectionProcess()
    }
    
    private func update(withViewModel viewModel: ViewModel) {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        firmwareLabel.text = viewModel.firmware
        batteryALabel.text = viewModel.batteryA
        batteryBLabel.text = viewModel.batteryB
        transmitterTimeLabel.text = viewModel.transmitterTime
        continueButton.isEnabled = true
    }
}

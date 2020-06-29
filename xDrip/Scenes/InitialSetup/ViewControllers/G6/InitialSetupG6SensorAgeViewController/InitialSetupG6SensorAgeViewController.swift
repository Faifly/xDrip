//
//  InitialSetupG6SensorAgeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 04.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupG6SensorAgeViewController: InitialSetupAbstractStepViewController {
    private let month: TimeInterval = 2592000.0
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    private let worker = InitialSetupDexcomG6SensorAgeWorker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "initial_sensor_age_screen_title".localized
        datePicker.maximumDate = Date()
        datePicker.minimumDate = Date() - month
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(onSaveButtonTap)
        )
    }
    
    @objc private func onSaveButtonTap() {
        guard worker.validateSensorAge(datePicker.date) else { return }
        worker.saveSensorAge(datePicker.date)
        
        let request = InitialSetup.CompleteCustomDeviceStep.Request(
            moreStepsExpected: true,
            step: InitialSetupG6Step.sensorAge
        )
        interactor?.doCompleteCustomDeviceStep(request: request)
    }
}

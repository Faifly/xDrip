//
//  SettingsTestBackfillViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.08.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class SettingsTestBackfillViewController: BaseSettingsViewController {
    var callback: ((SettingsTransmitter.TestBackfillConfiguration) -> Void)?
    
    private var days: String?
    private var minGlucose: String?
    private var maxGlucose: String?
    private var maxStepDeviation: String?
    private var isChaotic: Bool = true
    private var minutesBetweenReadings: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Test Data Backfill"
        setupTable()
        setupNavigationButtons()
    }
    
    private func setupTable() {
        let cells: [BaseSettings.Cell] = [
            .textInput(
                mainText: "Days to backfill",
                detailText: nil,
                textFieldText: "5",
                placeholder: "days",
                textFieldConfigurator: { textField in
                    textField.keyboardType = .numberPad
            }, textChangedHandler: { [weak self] text in
                self?.days = text
            }),
            .textInput(
                mainText: "Minutes between readings",
                detailText: nil,
                textFieldText: "5",
                placeholder: "min",
                textFieldConfigurator: { textField in
                    textField.keyboardType = .numberPad
            }, textChangedHandler: { [weak self] text in
                self?.minutesBetweenReadings = text
            }),
            .textInput(
                mainText: "Min glucose level mg/dl",
                detailText: nil,
                textFieldText: "50.0",
                placeholder: "mg/dl",
                textFieldConfigurator: { textField in
                    textField.keyboardType = .decimalPad
            }, textChangedHandler: { [weak self] text in
                self?.minGlucose = text
            }),
            .textInput(
                mainText: "Max glucose level mg/dl",
                detailText: nil,
                textFieldText: "250.0",
                placeholder: "mg/dl",
                textFieldConfigurator: { textField in
                    textField.keyboardType = .decimalPad
            }, textChangedHandler: { [weak self] text in
                self?.maxGlucose = text
            }),
            .textInput(
                mainText: "Max step deviation mg/dl",
                detailText: nil,
                textFieldText: "25.0",
                placeholder: "mg/dl",
                textFieldConfigurator: { textField in
                    textField.keyboardType = .decimalPad
            }, textChangedHandler: { [weak self] text in
                self?.maxStepDeviation = text
            }),
            .rightSwitch(
                text: "Chaotic",
                isSwitchOn: isChaotic,
                switchHandler: { [weak self] value in
                    self?.isChaotic = value
            })
        ]
        
        let section = BaseSettings.Section.normal(
            cells: cells,
            header: "BACKFILL DATA CONFIGURATION",
            footer: nil,
            headerView: nil,
            footerView: nil
        )
        
        let viewModel = BaseSettings.ViewModel(sections: [section])
        
        update(with: viewModel)
    }
    
    private func setupNavigationButtons() {
        let generateButton = UIBarButtonItem(
            title: "Generate",
            style: .done,
            target: self,
            action: #selector(onGenerate)
        )
        navigationItem.rightBarButtonItem = generateButton
    }
    
    @objc private func onGenerate() {
        let config = SettingsTransmitter.TestBackfillConfiguration(
            days: Int(days ?? "") ?? 5,
            minGlucose: Double(minGlucose ?? "") ?? 50.0,
            maxGlucose: Double(maxGlucose ?? "") ?? 250.0,
            maxStepDeviation: Double(maxStepDeviation ?? "") ?? 25.0,
            isChaotic: isChaotic,
            minutesBetweenReading: Int(minutesBetweenReadings ?? "") ?? 5
        )
        callback?(config)
    }
}

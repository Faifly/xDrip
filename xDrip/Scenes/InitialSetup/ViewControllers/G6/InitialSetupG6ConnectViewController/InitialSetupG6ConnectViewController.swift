//
//  InitialSetupG6ConnectViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class InitialSetupG6ConnectViewController: InitialSetupAbstractStepSettingsViewController {
    struct ViewModel {
        let firmware: String?
        let batteryA: String?
        let batteryB: String?
        let transmitterTime: String?
        let deviceName: String?
    }
    
    private let worker: InitialSetupDexcomG6ConnectionWorkerProtocol
    private lazy var continueButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "initial_connect_continue_button".localized,
            style: .done,
            target: self,
            action: #selector(onContinueTap)
        )
        button.isEnabled = true
        return button
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "close".localized,
            style: .plain,
            target: self,
            action: #selector(onCloseTap)
        )
        button.isEnabled = true
        return button
    }()
    
    required init() {
        worker = InitialSetupDexcomG6ConnectionWorker()
        super.init()
    }
    
    required init?(coder: NSCoder) {
        worker = InitialSetupDexcomG6ConnectionWorker()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        setupCloseButton()
        title = "initial_connect_screen_title".localized
        worker.onSuccessfulConnection = { [weak self] viewModel in
            guard let self = self else { return }
            self.update(withViewModel: viewModel)
        }
        worker.startConnectionProcess()
    }
    
    private func setupTable() {
        let rows: [BaseSettings.Cell] = [
            .info(
                mainText: "initial_connect_device_name".localized,
                detailText: nil,
                detailTextColor: nil,
                isLoading: true
            ),
            .info(
                mainText: "initial_connect_firmware".localized,
                detailText: nil,
                detailTextColor: nil,
                isLoading: true
            ),
            .info(
                mainText: "initial_connect_battery_a".localized,
                detailText: nil,
                detailTextColor: nil,
                isLoading: true
            ),
            .info(
                mainText: "initial_connect_battery_b".localized,
                detailText: nil,
                detailTextColor: nil,
                isLoading: true
            ),
            .info(
                mainText: "initial_connect_transmitter_age".localized,
                detailText: nil,
                detailTextColor: nil,
                isLoading: true
            )
        ]
        
        let section = BaseSettings.Section.normal(
            cells: rows,
            header: "initial_connect_in_progress_section_header".localized,
            footer: "initial_connect_in_progress_section_footer".localized
        )
        let viewModel = BaseSettings.ViewModel(sections: [section])
        update(with: viewModel)
    }
    
    private func setupContinueButton() {
        navigationItem.rightBarButtonItem = continueButton
    }
    
    private func setupCloseButton() {
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func onContinueTap() {
        let request = InitialSetup.CompleteCustomDeviceStep.Request(
            moreStepsExpected: true,
            step: InitialSetupG6Step.connect
        )
        interactor?.doCompleteCustomDeviceStep(request: request)
    }
    
    @objc private func onCloseTap() {
        interactor?.doClose()
    }
    
    private func update(withViewModel viewModel: ViewModel) {
        let rows: [BaseSettings.Cell] = [
            .info(
                mainText: "initial_connect_device_name".localized,
                detailText: viewModel.deviceName,
                detailTextColor: nil,
                isLoading: false
            ),
            .info(
                mainText: "initial_connect_firmware".localized,
                detailText: viewModel.firmware,
                detailTextColor: nil,
                isLoading: false
            ),
            .info(
                mainText: "initial_connect_battery_a".localized,
                detailText: viewModel.batteryA,
                detailTextColor: nil,
                isLoading: false
            ),
            .info(
                mainText: "initial_connect_battery_b".localized,
                detailText: viewModel.batteryB,
                detailTextColor: nil,
                isLoading: false
            ),
            .info(
                mainText: "initial_connect_transmitter_age".localized,
                detailText: viewModel.transmitterTime,
                detailTextColor: nil,
                isLoading: false
            )
        ]
        
        let section = BaseSettings.Section.normal(
            cells: rows,
            header: "initial_connect_finished_section_header".localized,
            footer: "initial_connect_finished_section_footer".localized
        )
        let viewModel = BaseSettings.ViewModel(sections: [section])
        update(with: viewModel)
        setupContinueButton()
    }
}

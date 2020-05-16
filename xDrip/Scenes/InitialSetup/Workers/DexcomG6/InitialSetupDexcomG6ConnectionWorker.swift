//
//  InitialSetupDexcomG6ConnectionWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol InitialSetupDexcomG6ConnectionWorkerProtocol: AnyObject {
    var onSuccessfulConnection: ((InitialSetupG6ConnectViewController.ViewModel) -> Void)? { get set }
    func startConnectionProcess()
}

final class InitialSetupDexcomG6ConnectionWorker: NSObject, InitialSetupDexcomG6ConnectionWorkerProtocol {
    var onSuccessfulConnection: ((InitialSetupG6ConnectViewController.ViewModel) -> Void)?
    private var requiredFields: Set<CGMDeviceMetadataType> = [
        .firmwareVersion,
        .batteryVoltageA,
        .batteryVoltageB,
        .transmitterTime
    ]
    
    func startConnectionProcess() {
        CGMDevice.current.updateSetupProgress(true)
        CGMController.shared.setupService(for: .dexcomG6)
        CGMController.shared.subscribeForMetadataEvents(listener: self) { [weak self] metadataType in
            guard let self = self else { return }
            self.requiredFields.remove(metadataType)
            self.handleSuccessfulConnection()
        }
        CGMController.shared.service?.connect()
    }
    
    private func handleSuccessfulConnection() {
        guard requiredFields.isEmpty else { return }
        
        CGMController.shared.unsubscribeFromMetadataEvents(listener: self)
        let device = CGMDevice.current
        guard let firmware = device.metadata(ofType: .firmwareVersion)?.value else { return }
        guard let voltageA = device.metadata(ofType: .batteryVoltageA)?.value else { return }
        guard let voltageB = device.metadata(ofType: .batteryVoltageB)?.value else { return }
        guard let transmitterTime = device.metadata(ofType: .transmitterTime)?.value else { return }
        CGMDevice.current.updateSetupProgress(false)
        
        let viewModel = InitialSetupG6ConnectViewController.ViewModel(
            firmware: firmware,
            batteryA: voltageA,
            batteryB: voltageB,
            transmitterTime: transmitterTime
        )
        onSuccessfulConnection?(viewModel)
    }
}

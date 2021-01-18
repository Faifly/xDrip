//
//  SettingsSensorInteractor.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsSensorBusinessLogic {
    func doLoad(request: SettingsSensor.Load.Request)
}

protocol SettingsSensorDataStore: AnyObject {
}

final class SettingsSensorInteractor: SettingsSensorBusinessLogic, SettingsSensorDataStore {
    var presenter: SettingsSensorPresentationLogic?
    var router: SettingsSensorRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsSensor.Load.Request) {
        let response = SettingsSensor.Load.Response()
        presenter?.presentLoad(response: response)
        
        updateData()
    }
    
    private func updateData() {
        let response = SettingsSensor.UpdateData.Response(
            device: CGMDevice.current,
            sensorCalibrations: Array(Calibration.allForCurrentSensor),
            startStopHandler: onStartStopSensor,
            deleteLastHandler: onDeleteLastCalibration,
            deleteAllHandler: onDeleteAllCalibrations,
            skipWarmsUpHandler: onSkipWarmUp(_:)
        )
        presenter?.presentData(response: response)
    }
    
    private func onStartStopSensor() {
        if CGMDevice.current.isSensorStarted {
            router?.showStopSensorConfirmation { [weak self] in
                self?.stopSensor()
            }
        } else {
            guard CGMDevice.current.isSetUp else {
                router?.showNoTransmitterAlert()
                return
            }
            router?.routeToStartSensor { [weak self] date in
                self?.startSensor(date: date)
            }
        }
    }
    
    private func onDeleteLastCalibration() {
        guard !Calibration.allForCurrentSensor.isEmpty else {
            router?.showNoCalibrationsAlert()
            return
        }
        router?.showDeleteLastCalibrationConfirmation { [weak self] in
            Calibration.deleteLast()
            self?.updateData()
        }
    }
    
    private func onDeleteAllCalibrations() {
        guard !Calibration.allForCurrentSensor.isEmpty else {
            router?.showNoCalibrationsAlert()
            return
        }
        router?.showDeleteAllCalibrationsConfirmation { [weak self] in
            Calibration.deleteAll()
            self?.updateData()
        }
    }
    
    private func onSkipWarmUp(_ skip: Bool) {
        guard skip else {
            User.current.settings.updateSkipWarmUp(false)
            NotificationCenter.default.postSettingsChangeNotification(setting: .warmUp)
            return
        }
        router?.showSkipWarmUpConfirmation { [weak self] confirmed in
            if confirmed {
                User.current.settings.updateSkipWarmUp(true)
                NotificationCenter.default.postSettingsChangeNotification(setting: .warmUp)
            }
            self?.updateData()
        }
    }
    
    private func stopSensor() {
        CGMDevice.current.updateSensorIsStarted(false)
        CGMDevice.current.sensorStartDate = nil
        CGMController.shared.notifyMetadataChanged(.sensorAge)
        updateData()
    }
    
    private func startSensor(date: Date) {
        CGMDevice.current.sensorStartDate = date
        CGMDevice.current.updateSensorIsStarted(true)
        CGMController.shared.notifyMetadataChanged(.sensorAge)
        updateData()
    }
}

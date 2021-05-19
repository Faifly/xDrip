//
//  CGMController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class CGMController {
    // MARK: Access
    static let shared = CGMController()
    private init() {}
    
    // MARK: Connection
    typealias ConnectionCallback = (_ isConnectionActive: Bool, _ isPaired: Bool) -> Void
    private var connectionListeners: [AnyHashable: ConnectionCallback] = [:]
    
    func subscribeForConnectionEvents(listener: AnyHashable, callback: @escaping ConnectionCallback) {
        connectionListeners[listener] = callback
    }
    
    func unsubscribeFromConnectionEvents(listener: AnyHashable) {
        connectionListeners.removeValue(forKey: listener)
    }
    
    // MARK: Glucose data
    typealias GlucoseDataCallback = (GlucoseReading?) -> Void
    private var glucoseDataListeners: [AnyHashable: GlucoseDataCallback] = [:]
    
    func subscribeForGlucoseDataEvents(listener: AnyHashable, callback: @escaping GlucoseDataCallback) {
        glucoseDataListeners[listener] = callback
    }
    
    func unsubscribeFromGlucoseDataEvents(listener: AnyHashable) {
        glucoseDataListeners.removeValue(forKey: listener)
    }
    
    // MARK: Metadata
    typealias MetadataCallback = (CGMDeviceMetadataType) -> Void
    private var metadataListeners: [AnyHashable: MetadataCallback] = [:]
    
    func subscribeForMetadataEvents(listener: AnyHashable, callback: @escaping MetadataCallback) {
        metadataListeners[listener] = callback
    }
    
    func unsubscribeFromMetadataEvents(listener: AnyHashable) {
        metadataListeners.removeValue(forKey: listener)
    }
        
    // MARK: Bluetooth service
    private(set) var service: CGMBluetoothService?
    
    func setupService(for type: CGMDeviceType) {
        #if targetEnvironment(simulator)
        injectBluetoothService(MockedBluetoothService(delegate: self))
        #else
        switch type {
        case .dexcomG6: injectBluetoothService(DexcomG6BluetoothService(delegate: self))
        case .mocked: injectBluetoothService(MockedBluetoothService(delegate: self))
        }
        #endif
    }
    
    func injectBluetoothService(_ service: CGMBluetoothService) {
        self.service = service
        
        if User.current.settings.deviceMode == .main {
            service.connect()
        }
    }
    
    func stopService() {
        self.service?.disconnect()
        self.service = nil
    }
    
    func notifyGlucoseChange(_ reading: GlucoseReading? = nil) {
        glucoseDataListeners.values.forEach { $0(reading) }
    }
    
    func notifyMetadataChanged(_ metadata: CGMDeviceMetadataType) {
        metadataListeners.values.forEach { $0(metadata) }
    }
}

extension CGMController: CGMBluetoothServiceDelegate {
    func serviceDidConnect(isPaired: Bool) {
        connectionListeners.values.forEach { $0(true, isPaired) }
    }
    
    func serviceDidDisconnect(isPaired: Bool) {
        connectionListeners.values.forEach { $0(false, isPaired) }
    }
    
    func serviceDidUpdateMetadata(_ metadata: CGMDeviceMetadataType, value: String) {
        CGMDevice.current.updateMetadata(ofType: metadata, value: value, withDate: Date())
        metadataListeners.values.forEach { $0(metadata) }
    }
    
    func serviceDidReceiveSensorGlucoseReading(raw: Double, filtered: Double, rssi: Double) {
        guard !CGMDevice.current.isWarmingUp else { return }
        if let reading = GlucoseReading.create(filtered: filtered, unfiltered: raw, rssi: rssi), reading.isValid {
            glucoseDataListeners.values.forEach { $0(reading) }
        }
    }
    
    func serviceDidReceiveGlucoseReading(calculatedValue: Double,
                                         calibrationState: DexcomG6CalibrationState?,
                                         date: Date,
                                         forBackfill: Bool) {
        guard !CGMDevice.current.isWarmingUp else { return }
        if GlucoseReading.reading(for: date, precisionInMinutes: 4) == nil {
            if let reading = GlucoseReading.createFromG6(calculatedValue: calculatedValue,
                                                         calibrationState: calibrationState,
                                                         date: date,
                                                         forBackfill: forBackfill), reading.isValid {
                glucoseDataListeners.values.forEach { $0(reading) }
            }
        } 
    }
    
    func serviceDidFail(withError error: CGMBluetoothServiceError) {
        let alert = UIAlertController(
            title: error.errorTitle ,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        
        switch error {
        case .bluetoothIsUnauthorized:
            let settingsAction = UIAlertAction(
                title: "bluetooth_error_alert_settings_button_title".localized,
                style: .default
            ) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
            }
            alert.addAction(settingsAction)
        default:
            break
        }
        
        AlertPresenter.shared.presentAlert(alert)
        serviceDidDisconnect(isPaired: false)
    }
}

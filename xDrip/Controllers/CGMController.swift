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
    typealias ConnectionCallback = (Bool) -> Void
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
        }
        #endif
    }
    
    func injectBluetoothService(_ service: CGMBluetoothService) {
        self.service = service
        service.connect()
    }
    
    func stopService() {
        self.service?.disconnect()
        self.service = nil
    }
    
    func notifyGlucoseChange() {
        glucoseDataListeners.values.forEach { $0(nil) }
    }
    
    func notifyMetadataChanged(_ metadata: CGMDeviceMetadataType) {
        metadataListeners.values.forEach { $0(metadata) }
    }
}

extension CGMController: CGMBluetoothServiceDelegate {
    func serviceDidConnect() {
        connectionListeners.values.forEach { $0(true) }
    }
    
    func serviceDidDisconnect() {
        connectionListeners.values.forEach { $0(false) }
    }
    
    func serviceDidUpdateMetadata(_ metadata: CGMDeviceMetadataType, value: String) {
        CGMDevice.current.updateMetadata(ofType: metadata, value: value, withDate: Date())
        metadataListeners.values.forEach { $0(metadata) }
    }
    
    func serviceDidReceiveGlucoseReading(raw: Double, filtered: Double, rssi: Double) {
        guard !CGMDevice.current.isWarmingUp else { return }
        if let reading = GlucoseReading.create(filtered: filtered, unfiltered: raw, rssi: rssi) {
            glucoseDataListeners.values.forEach { $0(reading) }
        }
    }
    
    func serviceDidFail(withError error: CGMBluetoothServiceError) {
        let alert = UIAlertController(
            title: "bluetooth_error_title".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        
        AlertPresenter.shared.presentAlert(alert)
    }
}

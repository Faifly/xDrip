//
//  CGMController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class CGMController {
    // MARK: Access
    static let shared = CGMController()
    private init() {}
    
    // MARK: Connection
    typealias ConnectionCallback = () -> Void
    private var connectionListeners: [AnyHashable: ConnectionCallback] = [:]
    
    func subscribeForConnectionEvents(listener: AnyHashable, callback: @escaping ConnectionCallback) {
        connectionListeners[listener] = callback
    }
    
    func unsubscribeFromConnectionEvents(listener: AnyHashable) {
        connectionListeners.removeValue(forKey: listener)
    }
    
    // MARK: Glucose data
    typealias GlucoseDataCallback = (GlucoseData) -> Void
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
        switch type {
        case .dexcomG6: service = DexcomG6BluetoothService(delegate: self)
        }
    }
}

extension CGMController: CGMBluetoothServiceDelegate {
    func serviceDidConnect() {
        connectionListeners.values.forEach { $0() }
    }
    
    func serviceDidUpdateMetadata(_ metadata: CGMDeviceMetadataType, value: String) {
        CGMDevice.current.updateMetadata(ofType: metadata, withDate: Date(), value: value)
        metadataListeners.values.forEach { $0(metadata) }
    }
    
    func serviceDidReceiveGlucoseReading(raw: Double, filtered: Double) {
        let entry = User.current.addGlucoseDataEntry(filtered)
        glucoseDataListeners.values.forEach { $0(entry) }
    }
    
    func serviceDidFail(withError error: CGMBluetoothServiceError) {
        
    }
}

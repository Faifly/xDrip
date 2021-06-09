//
//  SettingsSensorStateWorker.swift
//  xDrip
//
//  Created by Dmitry on 08.06.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation

protocol SettingsSensorStateWorkerLogic {
    func subscribeForMetadataEvents(callback: @escaping (CGMDeviceMetadataType) -> Void)
}

final class SettingsSensorStateWorker: SettingsSensorStateWorkerLogic {
    private let listenerID = "SettingsSensorStateWorker"
    func subscribeForMetadataEvents(callback: @escaping (CGMDeviceMetadataType) -> Void) {
        CGMController.shared.subscribeForMetadataEvents(listener: listenerID) { type in
            callback(type)
        }
    }
    
    deinit {
        CGMController.shared.unsubscribeFromMetadataEvents(listener: listenerID)
    }
}

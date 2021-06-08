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
    func subscribeForMetadataEvents(callback: @escaping (CGMDeviceMetadataType) -> Void) {
        CGMController.shared.subscribeForMetadataEvents(listener: self) { type in
            callback(type)
        }
    }
    
    deinit {
        CGMController.shared.unsubscribeFromMetadataEvents(listener: self)
    }
}

extension SettingsSensorStateWorker: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(1)
    }
    
    static func == (lhs: SettingsSensorStateWorker, rhs: SettingsSensorStateWorker) -> Bool {
        return true
    }
}

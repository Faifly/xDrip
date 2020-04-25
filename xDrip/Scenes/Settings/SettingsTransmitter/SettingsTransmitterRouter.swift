//
//  SettingsTransmitterRouter.swift
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

@objc protocol SettingsTransmitterRoutingLogic {
    
}

protocol SettingsTransmitterDataPassing {
    var dataStore: SettingsTransmitterDataStore? { get }
}

final class SettingsTransmitterRouter: NSObject, SettingsTransmitterRoutingLogic, SettingsTransmitterDataPassing {
    weak var viewController: SettingsTransmitterViewController?
    var dataStore: SettingsTransmitterDataStore?
    
    // MARK: Routing
    
}
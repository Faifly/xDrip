//
//  SettingsModeRootRouter.swift
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

@objc protocol SettingsModeRootRoutingLogic {
    
}

protocol SettingsModeRootDataPassing {
    var dataStore: SettingsModeRootDataStore? { get }
}

final class SettingsModeRootRouter: NSObject, SettingsModeRootRoutingLogic, SettingsModeRootDataPassing {
    weak var viewController: SettingsModeRootViewController?
    var dataStore: SettingsModeRootDataStore?
    
    // MARK: Routing
    
}

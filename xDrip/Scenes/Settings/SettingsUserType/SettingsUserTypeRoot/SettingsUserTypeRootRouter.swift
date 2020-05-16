//
//  SettingsUserTypeRootRouter.swift
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

protocol SettingsUserTypeRootRoutingLogic {
}

protocol SettingsUserTypeRootDataPassing {
    var dataStore: SettingsUserTypeRootDataStore? { get }
}

final class SettingsUserTypeRootRouter: SettingsUserTypeRootRoutingLogic, SettingsUserTypeRootDataPassing {
    weak var viewController: SettingsUserTypeRootViewController?
    weak var dataStore: SettingsUserTypeRootDataStore?
    
    // MARK: Routing
    
}

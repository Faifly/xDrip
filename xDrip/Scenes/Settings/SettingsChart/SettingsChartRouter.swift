//
//  SettingsChartRouter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 07.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol SettingsChartRoutingLogic {
    
}

protocol SettingsChartDataPassing {
    var dataStore: SettingsChartDataStore? { get }
}

final class SettingsChartRouter: NSObject, SettingsChartRoutingLogic, SettingsChartDataPassing {
    weak var viewController: SettingsChartViewController?
    var dataStore: SettingsChartDataStore?
    
    // MARK: Routing
    
}

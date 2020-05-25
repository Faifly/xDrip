//
//  NightscoutCloudConfigurationRouter.swift
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

protocol NightscoutCloudConfigurationRoutingLogic {
    func routeToExtraOptions()
}

protocol NightscoutCloudConfigurationDataPassing {
    var dataStore: NightscoutCloudConfigurationDataStore? { get }
}

final class NightscoutCloudConfigurationRouter: NightscoutCloudConfigurationDataPassing {
    weak var viewController: NightscoutCloudConfigurationViewController?
    weak var dataStore: NightscoutCloudConfigurationDataStore?
    
    // MARK: Routing
    func routeToExtraOptions() {
        let extraOptionsViewController = NightscoutCloudExtraOptionsViewController()
        viewController?.navigationController?.pushViewController(extraOptionsViewController, animated: true)
    }
}

extension NightscoutCloudConfigurationRouter: NightscoutCloudConfigurationRoutingLogic {
}

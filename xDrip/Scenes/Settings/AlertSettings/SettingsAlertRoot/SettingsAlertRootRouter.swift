//
//  SettingsAlertRootRouter.swift
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

protocol SettingsAlertRootRoutingLogic {
    func routeToAlertTypes()
}

protocol SettingsAlertRootDataPassing {
    var dataStore: SettingsAlertRootDataStore? { get }
}

final class SettingsAlertRootRouter: SettingsAlertRootRoutingLogic, SettingsAlertRootDataPassing {
    weak var viewController: SettingsAlertRootViewController?
    weak var dataStore: SettingsAlertRootDataStore?
    
    // MARK: Routing
    func routeToAlertTypes() {
        present(SettingsAlertTypesViewController())
    }
    
    private func present(_ viewController: UIViewController) {
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}

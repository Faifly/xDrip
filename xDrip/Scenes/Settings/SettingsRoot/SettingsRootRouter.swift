//
//  SettingsRootRouter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsRootRoutingLogic {
    func dismissSelf()
    func routeToUnits()
    func routeToChartSettings()
    func routeToAlertRoot()
    func routeToTransmitter()
}

protocol SettingsRootDataPassing {
    var dataStore: SettingsRootDataStore? { get }
}

final class SettingsRootRouter: SettingsRootRoutingLogic, SettingsRootDataPassing {
    weak var viewController: SettingsRootViewController?
    weak var dataStore: SettingsRootDataStore?
    
    // MARK: Routing
    
    func dismissSelf() {
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func routeToUnits() {
        present(SettingsUnitsViewController())
    }
    
    func routeToChartSettings() {
        present(SettingsChartViewController())
    }
    
    func routeToAlertRoot() {
        present(SettingsAlertRootViewController())
    }
    
    func routeToTransmitter() {
        present(SettingsTransmitterViewController())
    }
    
    private func present(_ viewController: UIViewController) {
        self.viewController?.splitViewController?.showDetailViewController(
            viewController.embedInNavigation(),
            sender: nil
        )
    }
}

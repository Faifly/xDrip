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
    func presentNotYetImplementedAlert()
    func showConnectionTestingAlert()
    func finishConnectionTestingAlert(message: String, icon: UIImage)
}

protocol NightscoutCloudConfigurationDataPassing {
    var dataStore: NightscoutCloudConfigurationDataStore? { get }
}

final class NightscoutCloudConfigurationRouter: NightscoutCloudConfigurationDataPassing, AlertPresentable {
    weak var viewController: NightscoutCloudConfigurationViewController?
    weak var dataStore: NightscoutCloudConfigurationDataStore?
    
    private weak var popUpController: PopUpViewController?
    
    func routeToExtraOptions() {
        let extraOptionsViewController = NightscoutCloudExtraOptionsViewController()
        viewController?.navigationController?.pushViewController(extraOptionsViewController, animated: true)
    }
    
    func showConnectionTestingAlert() {
        let popUpController = PopUpViewController()
        viewController?.present(popUpController, animated: true, completion: nil)
        self.popUpController = popUpController
    }
    
    func finishConnectionTestingAlert(message: String, icon: UIImage) {
        popUpController?.presentFinishAlert(message: message, icon: icon)
    }
}

extension NightscoutCloudConfigurationRouter: NightscoutCloudConfigurationRoutingLogic {}

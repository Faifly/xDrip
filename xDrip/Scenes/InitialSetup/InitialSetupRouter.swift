//
//  InitialSetupRouter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 28.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol InitialSetupRoutingLogic {
    func dismissScene()
    func showNextScene(_ viewController: UIViewController)
}

protocol InitialSetupDataPassing {
    var dataStore: InitialSetupDataStore? { get }
}

final class InitialSetupRouter: NSObject, InitialSetupRoutingLogic, InitialSetupDataPassing {
    weak var viewController: InitialSetupViewController?
    var dataStore: InitialSetupDataStore?
    
    // MARK: Routing
    
    func dismissScene() {
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func showNextScene(_ viewController: UIViewController) {
        guard let navigationController = self.viewController else { return }
        if navigationController.viewControllers.count == 0 {
            navigationController.viewControllers = [viewController]
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
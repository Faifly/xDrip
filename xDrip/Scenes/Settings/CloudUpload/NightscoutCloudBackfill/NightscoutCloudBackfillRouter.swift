//
//  NightscoutCloudBackfillRouter.swift
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

protocol NightscoutCloudBackfillRoutingLogic {
    func presentPopUp()
}

protocol NightscoutCloudBackfillDataPassing {
    var dataStore: NightscoutCloudBackfillDataStore? { get }
}

final class NightscoutCloudBackfillRouter: NightscoutCloudBackfillRoutingLogic, NightscoutCloudBackfillDataPassing {
    weak var viewController: NightscoutCloudBackfillViewController?
    weak var dataStore: NightscoutCloudBackfillDataStore?
    
    // MARK: Routing
    func presentPopUp() {
        let popUp = PopUpViewController()
        popUp.modalPresentationStyle = .overFullScreen
        popUp.okActionHandler = { [weak self] in
            self?.dismissScene()
        }
        
        viewController?.present(popUp, animated: true, completion: nil)
    }
    
    private func dismissScene() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}

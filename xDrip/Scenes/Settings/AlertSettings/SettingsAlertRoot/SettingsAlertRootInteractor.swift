//
//  SettingsAlertRootInteractor.swift
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

protocol SettingsAlertRootBusinessLogic {
    func doLoad(request: SettingsAlertRoot.Load.Request)
}

protocol SettingsAlertRootDataStore {
    
}

final class SettingsAlertRootInteractor: SettingsAlertRootBusinessLogic, SettingsAlertRootDataStore {
    var presenter: SettingsAlertRootPresentationLogic?
    var router: SettingsAlertRootRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsAlertRoot.Load.Request) {
        let response = SettingsAlertRoot.Load.Response()
        presenter?.presentLoad(response: response)
    }
}

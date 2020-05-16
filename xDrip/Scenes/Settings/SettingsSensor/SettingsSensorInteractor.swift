//
//  SettingsSensorInteractor.swift
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

protocol SettingsSensorBusinessLogic {
    func doLoad(request: SettingsSensor.Load.Request)
}

protocol SettingsSensorDataStore: AnyObject {
}

final class SettingsSensorInteractor: SettingsSensorBusinessLogic, SettingsSensorDataStore {
    var presenter: SettingsSensorPresentationLogic?
    var router: SettingsSensorRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsSensor.Load.Request) {
        let response = SettingsSensor.Load.Response()
        presenter?.presentLoad(response: response)
    }
}

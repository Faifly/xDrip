//
//  SettingsModeMasterInteractor.swift
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

protocol SettingsModeMasterBusinessLogic {
    func doLoad(request: SettingsModeMaster.Load.Request)
}

protocol SettingsModeMasterDataStore: AnyObject {
}

final class SettingsModeMasterInteractor: SettingsModeMasterBusinessLogic, SettingsModeMasterDataStore {
    var presenter: SettingsModeMasterPresentationLogic?
    var router: SettingsModeMasterRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: SettingsModeMaster.Load.Request) {
        let response = SettingsModeMaster.Load.Response(singleSelectionHandler: handleSingleSelection(_:))
        presenter?.presentLoad(response: response)
    }
    
    func handleSingleSelection(_ field: SettingsModeMaster.Field) {
        switch field {
        case .sensor: router?.routeToSensor()
        case .transmitter: router?.routeToTransmitter()
        }
    }
}

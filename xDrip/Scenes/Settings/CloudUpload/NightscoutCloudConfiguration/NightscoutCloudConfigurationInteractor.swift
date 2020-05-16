//
//  NightscoutCloudConfigurationInteractor.swift
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

protocol NightscoutCloudConfigurationBusinessLogic {
    func doLoad(request: NightscoutCloudConfiguration.Load.Request)
}

protocol NightscoutCloudConfigurationDataStore: AnyObject {    
}

final class NightscoutCloudConfigurationInteractor: NightscoutCloudConfigurationBusinessLogic,
    NightscoutCloudConfigurationDataStore {
    var presenter: NightscoutCloudConfigurationPresentationLogic?
    var router: NightscoutCloudConfigurationRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: NightscoutCloudConfiguration.Load.Request) {
        let response = NightscoutCloudConfiguration.Load.Response()
        presenter?.presentLoad(response: response)
    }
}

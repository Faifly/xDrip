//
//  HistoryRootInteractor.swift
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

protocol HistoryRootBusinessLogic {
    func doLoad(request: HistoryRoot.Load.Request)
    func doCancel(request: HistoryRoot.Cancel.Request)
}

protocol HistoryRootDataStore {
    
}

final class HistoryRootInteractor: HistoryRootBusinessLogic, HistoryRootDataStore {
    var presenter: HistoryRootPresentationLogic?
    var router: HistoryRootRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: HistoryRoot.Load.Request) {
        let response = HistoryRoot.Load.Response()
        presenter?.presentLoad(response: response)
    }
    
    func doCancel(request: HistoryRoot.Cancel.Request) {
        router?.dismissSelf()
    }
}
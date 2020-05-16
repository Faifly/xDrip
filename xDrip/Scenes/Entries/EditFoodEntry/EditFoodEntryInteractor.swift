//
//  EditFoodEntryInteractor.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol EditFoodEntryBusinessLogic {
    func doLoad(request: EditFoodEntry.Load.Request)
}

protocol EditFoodEntryDataStore: AnyObject {    
}

final class EditFoodEntryInteractor: EditFoodEntryBusinessLogic, EditFoodEntryDataStore {
    var presenter: EditFoodEntryPresentationLogic?
    var router: EditFoodEntryRoutingLogic?
    
    // MARK: Do something
    
    func doLoad(request: EditFoodEntry.Load.Request) {
        let response = EditFoodEntry.Load.Response()
        presenter?.presentLoad(response: response)
    }
}

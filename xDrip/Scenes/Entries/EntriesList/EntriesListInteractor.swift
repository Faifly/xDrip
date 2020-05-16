//
//  EntriesListInteractor.swift
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

protocol EntriesListBusinessLogic {
    func doLoad(request: EntriesList.Load.Request)
    func doCancel(request: EntriesList.Cancel.Request)
    func doDeleteEntry(request: EntriesList.DeleteEntry.Request)
    func doShowSelectedEntry(request: EntriesList.ShowSelectedEntry.Request)
}

protocol EntriesListDataStore: AnyObject {
}

final class EntriesListInteractor: EntriesListBusinessLogic, EntriesListDataStore {
    var presenter: EntriesListPresentationLogic?
    var router: EntriesListRoutingLogic?
    
    let entriesWorker: EntriesListEntryPersistenceWorker
    
    init(persistenceWorker: EntriesListEntryPersistenceWorker) {
        entriesWorker = persistenceWorker
    }
    
    // MARK: Do something
    
    func doLoad(request: EntriesList.Load.Request) {
        let entries = entriesWorker.fetchEntries()
        
        let response = EntriesList.Load.Response(entries: entries)
        presenter?.presentLoad(response: response)
    }
    
    func doCancel(request: EntriesList.Cancel.Request) {
        router?.dismissScene()
    }
    
    func doDeleteEntry(request: EntriesList.DeleteEntry.Request) {
        entriesWorker.deleteEntry(request.index)
    }
    
    func doShowSelectedEntry(request: EntriesList.ShowSelectedEntry.Request) {
        _ = entriesWorker.fetchEntries()[request.index]
        
        // add route to edit entry controller
    }
}

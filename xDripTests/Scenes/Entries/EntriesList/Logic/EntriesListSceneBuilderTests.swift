//
//  EntriesListSceneBuilderTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 31.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

class EntriesListSceneBuilderTests: XCTestCase {
    
    var window: UIWindow!
    var viewController: EntriesListViewController!
    let sut = EntriesListSceneBuilder()

    override func setUp() {
        super.setUp()
        
        window = UIWindow()
        setupEntriesListViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    private func setupEntriesListViewController() {
        let controller = UIStoryboard(board: .entries).instantiateViewController(withIdentifier: EntriesListRouter.entriesListNavigationControllerIdentifier) as! UINavigationController
        
        let entriesListViewController = controller.topViewController as! EntriesListViewController
        
        viewController = entriesListViewController
    }
    
    final class EntriesListBusinessLogicSpy: EntriesListBusinessLogic {
        var worker: EntriesListEntryPersistenceWorker?
        var presenter: EntriesListPresentationLogic?
        
        func doLoad(request: EntriesList.Load.Request) { }
        
        func doCancel(request: EntriesList.Cancel.Request) { }
        
        func doDeleteEntry(request: EntriesList.DeleteEntry.Request) { }
        
        func doShowSelectedEntry(request: EntriesList.ShowSelectedEntry.Request) { }
        
        func inject(persistenceWorker: EntriesListEntryPersistenceWorker) {
            worker = persistenceWorker
        }
    }
    
    final class EntriesListPresentationLogicSpy: EntriesListPresentationLogic {
        var worker: EntriesListFormattingWorker?
        
        func presentLoad(response: EntriesList.Load.Response) { }
        
        func inject(formattingWorker: EntriesListFormattingWorker) {
            worker = formattingWorker
        }
    }
    
    func loadView() {
        window.addSubview(viewController.view)
        RunLoop.current.run(until: Date())
    }
    
    func testConfigurateForCarbs() {
        let presenterSpy = EntriesListPresentationLogicSpy()
        let interactorSpy = EntriesListBusinessLogicSpy()
        interactorSpy.presenter = presenterSpy
        
        viewController.interactor = interactorSpy
        
        sut.configureSceneForCarbs(viewController)
        
        loadView()
        
        XCTAssertTrue(interactorSpy.worker is EntriesListCarbsPersistenceWorker)
        XCTAssertTrue(presenterSpy.worker is EntriesListCarbsFormattingWorker)
    }
    
    func testConfigurateForBolus() {
        let presenterSpy = EntriesListPresentationLogicSpy()
        let interactorSpy = EntriesListBusinessLogicSpy()
        interactorSpy.presenter = presenterSpy
        
        viewController.interactor = interactorSpy
        
        sut.configureSceneForBolus(viewController)
        
        loadView()
        
        XCTAssertTrue(interactorSpy.worker is EntriesListBolusPersistenceWorker)
        XCTAssertTrue(presenterSpy.worker is EntriesListBolusFormattingWorker)
    }
}

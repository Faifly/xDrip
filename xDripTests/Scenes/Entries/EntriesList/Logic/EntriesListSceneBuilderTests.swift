//
//  EntriesListSceneBuilderTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 31.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable implicitly_unwrapped_optional

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
        viewController = EntriesListViewController(
            persistenceWorker: EntriesListCarbsPersistenceWorker(),
            formattingWorker: EntriesListCarbsFormattingWorker()
        )
    }
    
    final class EntriesListBusinessLogicSpy: EntriesListBusinessLogic {
        var worker: EntriesListEntryPersistenceWorker?
        var presenter: EntriesListPresentationLogic?
        
        func doUpdateData(request: EntriesList.UpdateData.Request) { }
        
        func doCancel(request: EntriesList.Cancel.Request) { }
        
        func doDeleteEntry(request: EntriesList.DeleteEntry.Request) { }
        
        func doShowSelectedEntry(request: EntriesList.ShowSelectedEntry.Request) { }
        
        func inject(persistenceWorker: EntriesListEntryPersistenceWorker) {
            worker = persistenceWorker
        }
    }
    
    final class EntriesListPresentationLogicSpy: EntriesListPresentationLogic {
        var worker: EntriesListFormattingWorker?
        
        func presentUpdateData(response: EntriesList.UpdateData.Response) { }
        
        func inject(formattingWorker: EntriesListFormattingWorker) {
            worker = formattingWorker
        }
    }
    
    func loadView() {
        window.addSubview(viewController.view)
        RunLoop.current.run(until: Date())
    }
    
    func testConfigurateForCarbs() {
        let builder = EntriesListSceneBuilder()
        let viewController = builder.createSceneForCarbs()
        
        let interactor = viewController.interactor as? EntriesListInteractor
        let presenter = interactor?.presenter as? EntriesListPresenter
        
        XCTAssertTrue(interactor?.entriesWorker is EntriesListCarbsPersistenceWorker)
        XCTAssertTrue(presenter?.formattingWorker is EntriesListCarbsFormattingWorker)
    }
    
    func testConfigurateForBolus() {
        let builder = EntriesListSceneBuilder()
        let viewController = builder.createSceneForBolus()
        
        let interactor = viewController.interactor as? EntriesListInteractor
        let presenter = interactor?.presenter as? EntriesListPresenter
        
        XCTAssertTrue(interactor?.entriesWorker is EntriesListInsulinPersistenceWorker)
        XCTAssertTrue(presenter?.formattingWorker is EntriesListInsulinFormattingWorker)
    }
}

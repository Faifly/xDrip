//
//  EntriesListViewControllerTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class EntriesListViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: EntriesListViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupEntriesListViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupEntriesListViewController() {
        sut = EntriesListViewController(
            persistenceWorker: EntriesListCarbsPersistenceWorker(),
            formattingWorker: EntriesListCarbsFormattingWorker()
        )
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class EntriesListBusinessLogicSpy: EntriesListBusinessLogic {
        var presenter: EntriesListPresentationLogic?
        
        var doLoadCalled = false
        var cancelCalled = false
        var showSelectedEntryCalled = false
        var deleteEntryCalled = false
        var worker: EntriesListEntryPersistenceWorker?
        
        func doUpdateData(request: EntriesList.UpdateData.Request) {
            doLoadCalled = true
        }
        
        func doCancel(request: EntriesList.Cancel.Request) {
            cancelCalled = true
        }
        
        func doShowSelectedEntry(request: EntriesList.ShowSelectedEntry.Request) {
            showSelectedEntryCalled = true
        }
        
        func doDeleteEntry(request: EntriesList.DeleteEntry.Request) {
            deleteEntryCalled = true
        }
        
        func inject(persistenceWorker: EntriesListEntryPersistenceWorker) {
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = EntriesListBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let items = generateDummyData()
        let viewModel = EntriesList.UpdateData.ViewModel(items: items, editEnabled: false)
        
        // When
        loadView()
        sut.displayUpdateData(viewModel: viewModel)
        
        guard let tableView = sut.view.subviews.first(where: { $0 is UITableView }) as? UITableView else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        // Then
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 20)
    }
    
    func testDeleteEntry() {
        let spy = EntriesListBusinessLogicSpy()
        sut.interactor = spy
        
        let items = generateDummyData()
        let viewModel = EntriesList.UpdateData.ViewModel(items: items, editEnabled: true)
        
        // When
        loadView()
        sut.displayUpdateData(viewModel: viewModel)
        
        guard let tableView = sut.view.subviews.first(where: { $0 is UITableView }) as? UITableView else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        // Then
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 20)
        
        guard let tableController = tableView.delegate as? EntriesListTableController else {
            XCTFail("Cannot obtaint table controller")
            return
        }
        
        let indexPath = IndexPath(row: 10, section: 0)
        tableController.tableView(tableView, commit: .delete, forRowAt: indexPath)
        
        XCTAssertTrue(spy.deleteEntryCalled)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 19)
    }
    
    func testShowSelectedEntry() {
        let spy = EntriesListBusinessLogicSpy()
        sut.interactor = spy
        
        let items = generateDummyData()
        let viewModel = EntriesList.UpdateData.ViewModel(items: items, editEnabled: false)
        
        // When
        loadView()
        sut.displayUpdateData(viewModel: viewModel)
        
        guard let tableView = sut.view.subviews.first(where: { $0 is UITableView }) as? UITableView else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        // Then
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 20)
        
        guard let tableController = tableView.delegate as? EntriesListTableController else {
            XCTFail("Cannot obtaint table controller")
            return
        }
        
        let indexPath = IndexPath(row: 10, section: 0)
        tableController.tableView(tableView, didSelectRowAt: indexPath)
        
        XCTAssertTrue(spy.showSelectedEntryCalled)
    }
    
    func testCancelHandler() {
        // Given
        let spy = EntriesListBusinessLogicSpy()
        sut.interactor = spy
        loadView()
        
        guard let target = sut.navigationItem.leftBarButtonItem?.target else {
            fatalError()
        }
        guard let action = sut.navigationItem.leftBarButtonItem?.action else {
            fatalError()
        }
        
        // When
        _ = target.perform(action)
        
        // Given
        XCTAssertTrue(spy.cancelCalled)
    }
    
    func testEditButtonTap() {
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        guard let rightBarButton = sut.navigationItem.rightBarButtonItem else {
            XCTFail("Cannot obtain bar button")
            return
        }
        
        XCTAssertTrue(tableView.isEditing == false)
        
        _ = rightBarButton.target?.perform(rightBarButton.action, with: nil)
        
        XCTAssertTrue(tableView.isEditing == true)
    }
    
    func testLoadWithCarbsWorkers() {
        CarbEntriesWorker.fetchAllCarbEntries().forEach { entry in
            CarbEntriesWorker.deleteCarbsEntry(entry)
        }
        
        CarbEntriesWorker.addCarbEntry(amount: 0.0, foodType: nil, date: Date())
        
        sut = EntriesListViewController(
            persistenceWorker: EntriesListCarbsPersistenceWorker(),
            formattingWorker: EntriesListCarbsFormattingWorker()
        )
        
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 1)
        
        guard let tableController = tableView.delegate as? EntriesListTableController else {
            XCTFail("Cannot obtaint table controller")
            return
        }
        
        tableController.tableView(tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 0)
    }
    
    func testLoadWithBolusWorkers() {
        InsulinEntriesWorker.fetchAllBolusEntries().forEach { entry in
            InsulinEntriesWorker.deleteInsulinEntry(entry)
        }
        InsulinEntriesWorker.addBolusEntry(amount: 0.0, date: Date())
        
        sut = EntriesListViewController(
            persistenceWorker: EntriesListInsulinPersistenceWorker(type: .bolus),
            formattingWorker: EntriesListInsulinFormattingWorker()
        )
        
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 1)
        
        guard let tableController = tableView.delegate as? EntriesListTableController else {
            XCTFail("Cannot obtaint table controller")
            return
        }
        
        tableController.tableView(tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 0)
    }
    
    func testLoadWithTrainingsWorkers() {
        TrainingEntriesWorker.fetchAllTrainings().forEach { entry in
            TrainingEntriesWorker.deleteTrainingEntry(entry)
        }
        TrainingEntriesWorker.addTraining(duration: 1.1, intensity: .high, date: Date())
        
        sut = EntriesListViewController(
            persistenceWorker: EntriesListTrainingsPersistenceWorker(),
            formattingWorker: EntriesListTrainingsFormattingWorker()
        )
        
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 1)
        
        guard let tableController = tableView.delegate as? EntriesListTableController else {
            XCTFail("Cannot obtaint table controller")
            return
        }
        
        tableController.tableView(tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 0)
    }
    
    func testLoadWithBasalsWorkers() {
        InsulinEntriesWorker.fetchAllBasalEntries().forEach { entry in
            InsulinEntriesWorker.deleteInsulinEntry(entry)
        }
        InsulinEntriesWorker.addBasalEntry(amount: 0.0, date: Date())
        
        sut = EntriesListViewController(
            persistenceWorker: EntriesListInsulinPersistenceWorker(type: .basal),
            formattingWorker: EntriesListInsulinFormattingWorker()
        )
        
        loadView()
        
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first else {
            XCTFail("Cannot obtain tableView")
            return
        }
        
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 1)
        
        guard let tableController = tableView.delegate as? EntriesListTableController else {
            XCTFail("Cannot obtaint table controller")
            return
        }
        
        tableController.tableView(tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 0)
    }
    
    // Helpers
    
    func generateDummyData(sectionCount: Int = 1, rowCount: Int = 20) -> [EntriesList.SectionViewModel] {
        var data = [EntriesList.SectionViewModel]()
        
         for index in 0 ..< sectionCount {
             let title = "title\(index)"
             var cellViewModels = [EntriesListTableViewCell.ViewModel]()
             
             for jIndex in 0 ..< rowCount {
                 let value = "value\(jIndex)"
                 let date = "date\(jIndex)"
                 
                 let viewModel = EntriesListTableViewCell.ViewModel(value: value, date: date)
                 cellViewModels.append(viewModel)
             }
             
             let sectionViewModel = EntriesList.SectionViewModel(title: title, items: cellViewModels)
             data.append(sectionViewModel)
         }
        
        return data
    }
}

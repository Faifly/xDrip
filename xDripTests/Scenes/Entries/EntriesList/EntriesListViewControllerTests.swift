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
import AKUtils

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
        
        func doLoad(request: EntriesList.Load.Request) {
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
        let viewModel = EntriesList.Load.ViewModel(items: items)
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
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
        let viewModel = EntriesList.Load.ViewModel(items: items)
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
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
        
        dispatchAfter(seconds: 1) {
            let indexPath = IndexPath(row: 10, section: 0)
            tableController.tableView(tableView, commit: .delete, forRowAt: indexPath)
            
            XCTAssertTrue(spy.deleteEntryCalled)
            XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 19)
        }
    }
    
    func testShowSelectedEntry() {
        let spy = EntriesListBusinessLogicSpy()
        sut.interactor = spy
        
        let items = generateDummyData()
        let viewModel = EntriesList.Load.ViewModel(items: items)
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
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
        
        let target = sut.navigationItem.leftBarButtonItem!.target!
        let action = sut.navigationItem.leftBarButtonItem!.action!
        
        // When
        _ = target.perform(action)
        
        // Given
        XCTAssertTrue(spy.cancelCalled)
    }
    
    // Helpers
    
    func generateDummyData(sectionCount: Int = 1, rowCount: Int = 20) -> [EntriesList.SectionViewModel] {
        var data = [EntriesList.SectionViewModel]()
        
         for i in 0 ..< sectionCount {
             let title = "title\(i)"
             var cellViewModels = [EntriesListTableViewCell.ViewModel]()
             
             for j in 0 ..< rowCount {
                 let value = "value\(j)"
                 let date = "date\(j)"
                 
                 let viewModel = EntriesListTableViewCell.ViewModel(value: value, date: date)
                 cellViewModels.append(viewModel)
             }
             
             let sectionViewModel = EntriesList.SectionViewModel(title: title, items: cellViewModels)
             data.append(sectionViewModel)
         }
        
        return data
    }
}

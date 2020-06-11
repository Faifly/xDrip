//
//  EntriesListTableControllerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip

// swiftlint:disable implicitly_unwrapped_optional

class EntriesListTableControllerTests: XCTestCase {
    var window: UIWindow!
    var viewController: EntriesListViewController!
    var tableView: UITableView!
    
    let sut = EntriesListTableController()
    
    var calledDelete = false
    var calledSelect = false
    
    override func setUp() {
        super.setUp()
        
        sut.didDeleteEntry = { indexPath in
            self.calledDelete = true
        }
        
        sut.didSelectEntry = { indexPath in
            self.calledSelect = true
        }
        
        window = UIWindow()
        setupEntriesListViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    func setupEntriesListViewController() {
        viewController = EntriesListViewController(
            persistenceWorker: EntriesListCarbsPersistenceWorker(),
            formattingWorker: EntriesListCarbsFormattingWorker()
        )
    }
    
    func loadView() {
        window.addSubview(viewController.view)
        RunLoop.current.run(until: Date())
        
        guard let tableView = viewController.view.subviews.first(
            where: { $0 is UITableView }
        ) as? UITableView else { return }
        
        tableView.delegate = sut
        tableView.dataSource = sut
        
        self.tableView = tableView
    }
    
    func testReload() {
        loadView()
        
        sut.reload(with: [])
        var data = generateDummyData(sectionCount: 2)
        sut.reload(with: data)
        tableView.reloadData()
        
        XCTAssertTrue(tableView.numberOfSections == 2)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 20)
        XCTAssertTrue(sut.tableView(tableView, titleForHeaderInSection: 1) == "title1")
        
        data.removeLast()
        sut.reload(with: data)
        tableView.reloadData()
        
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 20)
        XCTAssertTrue(sut.tableView(tableView, titleForHeaderInSection: 0) == "title0")
    }

    func testSelectEntryCall() {
        loadView()
        
        sut.reload(with: [])
        let data = generateDummyData()
        sut.reload(with: data)
        tableView.reloadData()
        
        let indexPath = IndexPath(row: 10, section: 0)
        sut.tableView(tableView, didSelectRowAt: indexPath)
        
        XCTAssertTrue(calledSelect)
    }
    
    func testDeleteEntry() {
        loadView()
        
        sut.reload(with: [])
        let data = generateDummyData()
        sut.reload(with: data)
        tableView.reloadData()
        
        let indexPath = IndexPath(row: 10, section: 0)
        
        sut.tableView(tableView, commit: .delete, forRowAt: indexPath)
        
        XCTAssertTrue(calledDelete)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 19)
    }
    
    func testTableViewConfiguration() {
        loadView()
        
        sut.reload(with: [])
        let data = generateDummyData()
        sut.reload(with: data)
        tableView.reloadData()
        
        let indexPath = IndexPath(row: 10, section: 0)
        
        XCTAssertTrue(sut.tableView(tableView, canMoveRowAt: indexPath) == false)
        XCTAssertTrue(sut.tableView(tableView, canEditRowAt: indexPath) == false)
        
        tableView.isEditing = true
        
        XCTAssertTrue(sut.tableView(tableView, canEditRowAt: indexPath) == true)
        
        tableView.isEditing = false
    }
    
    func testCellForRow() {
        loadView()
        
        sut.reload(with: [])
        let data = generateDummyData()
        sut.reload(with: data)
        tableView.reloadData()
        
        let indexPath = IndexPath(row: 10, section: 0)
        
        let cell = sut.tableView(tableView, cellForRowAt: indexPath)
        
        XCTAssertTrue(cell is EntriesListTableViewCell)
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

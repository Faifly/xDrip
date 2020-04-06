//
//  EntriesListTableControllerTests.swift
//  xDripTests
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip
import AKUtils

class EntriesListTableControllerTests: XCTestCase {

    var window: UIWindow!
    
    var sut: EntriesListTableController!
    
    var tableView = UITableView()
    
    var calledDelete = false
    var calledSelect = false
    
    override func setUp() {
        super.setUp()
        
        window = UIWindow()
        setupEntriesListTableController()
    }
    
    func setupEntriesListTableController() {
        sut = EntriesListTableController()
        
        sut.didDeleteEntry = { indexPath in
            self.calledDelete = true
        }
        
        sut.didSelectEntry = { indexPath in
            self.calledSelect = true
        }
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    func loadView() {
        window.addSubview(tableView)
        RunLoop.current.run(until: Date())
        
        sut.tableView = tableView
    }
    
    func testReload() {
        loadView()
        
        var data = generateDummyData(sectionCount: 2)
        sut.reload(with: data)
        
        XCTAssertTrue(tableView.numberOfSections == 2)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 20)
        XCTAssertTrue(sut.tableView(tableView, titleForHeaderInSection: 1) == "title1")
        
        data.removeLast()
        sut.reload(with: data)
        
        XCTAssertTrue(tableView.numberOfSections == 1)
        XCTAssertTrue(tableView.numberOfRows(inSection: 0) == 20)
        XCTAssertTrue(sut.tableView(tableView, titleForHeaderInSection: 0) == "title0")
    }

    func testSelectEntryCall() {
        loadView()
        
        let data = generateDummyData()
        sut.reload(with: data)
        
        let indexPath = IndexPath(row: 10, section: 0)
        sut.tableView(tableView, didSelectRowAt: indexPath)
        
        XCTAssertTrue(calledSelect)
    }
    
    func testDeleteEntry() {
        loadView()
        
        dispatchAfter(seconds: 1) {
            let data = self.generateDummyData()
            self.sut.reload(with: data)
            
            let indexPath = IndexPath(row: 10, section: 0)
            
            self.sut.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
            
            XCTAssertTrue(self.calledDelete)
            XCTAssertTrue(self.tableView.numberOfRows(inSection: 0) == 19)
        }
    }
    
    func test() {
        loadView()
        
        let data = generateDummyData()
        sut.reload(with: data)
        
        let indexPath = IndexPath(row: 10, section: 0)
        
        XCTAssertTrue(sut.tableView(tableView, canMoveRowAt: indexPath) == false)
        XCTAssertTrue(sut.tableView(tableView, canEditRowAt: indexPath) == false)
        
        tableView.isEditing = true
        
        XCTAssertTrue(sut.tableView(tableView, canEditRowAt: indexPath) == true)
        
        tableView.isEditing = false
    }
    
    func testCellForRow() {
        loadView()
        
        let data = generateDummyData()
        sut.reload(with: data)
        
        let indexPath = IndexPath(row: 10, section: 0)
        
        let cell = sut.tableView(tableView, cellForRowAt: indexPath)
        
        XCTAssertTrue(cell is EntriesListTableViewCell)
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

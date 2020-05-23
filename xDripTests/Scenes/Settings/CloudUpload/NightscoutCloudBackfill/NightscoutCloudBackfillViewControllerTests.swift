//
//  NightscoutCloudBackfillViewControllerTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class NightscoutCloudBackfillViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: NightscoutCloudBackfillViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupNightscoutCloudBackfillViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupNightscoutCloudBackfillViewController() {
        sut = NightscoutCloudBackfillViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class NightscoutCloudBackfillBusinessLogicSpy: NightscoutCloudBackfillBusinessLogic {
        var doLoadCalled = false
        var doSendCalled = false
        
        func doLoad(request: NightscoutCloudBackfill.Load.Request) {
            doLoadCalled = true
        }
        
        func doSend(request: NightscoutCloudBackfill.Send.Request) {
            doSendCalled = true
        }
    }
    
    final class NightscoutCloudBackfillRoutingLogicSpy: NightscoutCloudBackfillRoutingLogic {
        var presentPopUpCalled = false
        
        func presentPopUp() {
            presentPopUpCalled = true
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = NightscoutCloudBackfillBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let tableViewModel = BaseSettings.ViewModel(sections: [])
        let viewModel = NightscoutCloudBackfill.Load.ViewModel(tableViewModel: tableViewModel)
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
        // Then
    }
    
    func testDoSend() {
        // Given
        let spy = NightscoutCloudBackfillBusinessLogicSpy()
        sut.interactor = spy
        
        loadView()
        
        let button = sut.navigationItem.rightBarButtonItem
        
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(spy.doSendCalled)
    }
    
    func testPresentPopUpCalled() {
        loadView()
        
        let spy = NightscoutCloudBackfillRoutingLogicSpy()
        if let interactor = sut.interactor as? NightscoutCloudBackfillInteractor {
            interactor.router = spy
        }
        
        let button = sut.navigationItem.rightBarButtonItem
        
        // When
        _ = button?.target?.perform(button?.action, with: nil)
        // Then
        XCTAssertTrue(spy.presentPopUpCalled)
    }
    
    func testDateChangedHandler() {
        loadView()
        
        let cellType = PickerExpandableTableViewCell.self
        guard let tableView = sut.view.subviews.compactMap({ $0 as? UITableView }).first,
            let datePickerCell = tableView.getCell(of: cellType, at: IndexPath(row: 0, section: 0)) else {
                XCTFail("Cannot obtain datePickerCell")
                return
        }
        
        datePickerCell.togglePickerVisibility()
        
        guard let stackView = datePickerCell.contentView.subviews.compactMap({ $0 as? UIStackView }).first,
            let datePicker = stackView.arrangedSubviews.first as? UIDatePicker else {
                XCTFail("Cannot obtain datePicker")
                return
        }
        
        let date = Date().addingTimeInterval(3600)
        
        datePicker.date = date
        datePicker.sendActions(for: .valueChanged)
    }
}

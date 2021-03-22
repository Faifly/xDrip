//
//  HistoryRootViewControllerTests.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import xDrip
import XCTest

// swiftlint:disable implicitly_unwrapped_optional

final class HistoryRootViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: HistoryRootViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupHistoryRootViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupHistoryRootViewController() {
        sut = HistoryRootViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class HistoryRootBusinessLogicSpy: HistoryRootBusinessLogic {
        var doLoadCalled = false
        var cancelCalled = false
        var changeChartDateCalled = false
        var changeChartTimeFrameCalled = false
        
        func doLoad(request: HistoryRoot.Load.Request) {
            doLoadCalled = true
        }
        
        func doCancel(request: HistoryRoot.Cancel.Request) {
            cancelCalled = true
        }
        
        func doChangeChartDate(request: HistoryRoot.ChangeEntriesChartDate.Request) {
            changeChartDateCalled = true
        }
        
        func doChangeChartTimeFrame(request: HistoryRoot.ChangeEntriesChartTimeFrame.Request) {
            changeChartTimeFrameCalled = true
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = HistoryRootBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        DispatchQueue.main.async {
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
        }
    }
    
    func testDisplayLoad() {
        // Given
        let viewModel = HistoryRoot.Load.ViewModel(globalTimeInterval: TimeInterval.zero)
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
        // Then
    }
    
    func testCancelHandler() {
        // Given
        let spy = HistoryRootBusinessLogicSpy()
        sut.interactor = spy
        loadView()
        
        guard let target = sut.navigationItem.leftBarButtonItem?.target else {
return //            fatalError() 
        }
        guard let action = sut.navigationItem.leftBarButtonItem?.action else {
            fatalError()
        }
        
        // When
        _ = target.perform(action)
        
        // Given
        XCTAssertTrue(spy.cancelCalled)
    }
    
    func testTimeFrameValueChanged() {
        let spy = HistoryRootBusinessLogicSpy()
        sut.interactor = spy
        loadView()
        
        guard let segmentControl = sut.view.subviews.compactMap({ $0 as? UISegmentedControl }).first else {
            XCTFail("Cannot obtain segment control")
            return
        }
        
        segmentControl.selectedSegmentIndex = 1
        segmentControl.sendActions(for: .valueChanged)
        
        DispatchQueue.main.async {
            XCTAssertTrue(spy.changeChartTimeFrameCalled)
        }
    }
    
    func testDisplayChartTimeFrameChange() {
        loadView()
        
        guard let segmentControl = sut.view.subviews.compactMap({ $0 as? UISegmentedControl }).first else {
            XCTFail("Cannot obtain segment control")
            return
        }
        
        segmentControl.selectedSegmentIndex = 1
        segmentControl.sendActions(for: .valueChanged)
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sendActions(for: .valueChanged)
    }
    
    func testDateButtonsCallBack() {
        let spy = HistoryRootBusinessLogicSpy()
        sut.interactor = spy
        loadView()
        
        guard
            let view = sut.view.findView(with: "buttonsStackViewContainer"),
            let stackView = view.subviews.first as? UIStackView
        else {
            XCTFail("Cannot obtain buttons stack view")
            return
        }
        
        let leftArrowButton = stackView.arrangedSubviews.first(where: { $0.tag == 0 }) as? UIButton
        let toggleButton = stackView.arrangedSubviews.first(where: { $0.tag == 1 }) as? UIButton
        let rightArrowButton = stackView.arrangedSubviews.first(where: { $0.tag == 2 }) as? UIButton
        
        leftArrowButton?.sendActions(for: .touchUpInside)
        XCTAssertTrue(spy.changeChartDateCalled)
        spy.changeChartDateCalled = false
        
        rightArrowButton?.sendActions(for: .touchUpInside)
        XCTAssertTrue(spy.changeChartDateCalled)
        spy.changeChartDateCalled = false
        
        toggleButton?.sendActions(for: .touchUpInside)
        
        guard
            let scrollView = sut.view.subviews.compactMap({ $0 as? UIScrollView }).first,
            let container = scrollView.subviews.compactMap({ $0 as? UIStackView }).first,
            let datePicker = container.arrangedSubviews.compactMap({ $0 as? UIDatePicker }).first
        else {
            XCTFail("Cannot obtain date picker")
            return
        }
        
        datePicker.sendActions(for: .valueChanged)
        XCTAssertTrue(spy.changeChartDateCalled)
        toggleButton?.sendActions(for: .touchUpInside)
    }
}

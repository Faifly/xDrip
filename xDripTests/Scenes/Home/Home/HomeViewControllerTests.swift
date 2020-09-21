//
//  HomeViewControllerTests.swift
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

final class HomeViewControllerTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: HomeViewController!
    var window: UIWindow!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupHomeViewController()
    }
    
    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupHomeViewController() {
        sut = HomeViewController()
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    // MARK: Test doubles
    
    final class HomeBusinessLogicSpy: HomeBusinessLogic {
        var doLoadCalled = false
        var doShowBolusListCalled = false
        var doShowCarbsListCalled = false
        var doShowBasalsListCalled = false
        var doShowTrainingsListCalled = false
        
        func doLoad(request: Home.Load.Request) {
            doLoadCalled = true
        }
        
        func doShowEntriesList(request: Home.ShowEntriesList.Request) {
            switch request.entriesType {
            case .bolus:
                doShowBolusListCalled = true
            case .carbs:
                doShowCarbsListCalled = true
            case .basal:
                doShowBasalsListCalled = true
            case .training:
                doShowTrainingsListCalled = true
            default:
                break
            }
        }
        
        func doChangeGlucoseChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request) {
        }
        func doChangeBolusChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request) {
        }
        func doChangeCarbsChartTimeFrame(request: Home.ChangeEntriesChartTimeFrame.Request) {
        }
        func doUpdateGlucoseDataView(request: Home.GlucoseDataViewUpdate.Request) {
        }
    }
    
    // MARK: Tests
    
    func testShouldDoLoadWhenViewIsLoaded() {
        // Given
        let spy = HomeBusinessLogicSpy()
        sut.interactor = spy
        
        // When
        loadView()
        
        // Then
        XCTAssertTrue(spy.doLoadCalled, "viewDidLoad() should ask the interactor to do load")
    }
    
    func testDisplayLoad() {
        // Given
        let viewModel = Home.Load.ViewModel()
        
        // When
        loadView()
        sut.displayLoad(viewModel: viewModel)
        
        // Then
    }
    
    func testSubscribeToViewsButtonEvents() {
        // Given
        let spy = HomeBusinessLogicSpy()
        sut.interactor = spy
        let mirror = HomeViewControllerMirror(viewController: sut)
        
        // When
        loadView()
        
        mirror.carbsHistoryView?.chartButtonClicked()
        mirror.bolusHistoryView?.chartButtonClicked()
        mirror.optionsView?.onAllTrainingsTapped(sender: UITapGestureRecognizer())
        mirror.optionsView?.onAllBasalTapped(sender: UITapGestureRecognizer())
        // Then
        
        XCTAssertTrue(spy.doShowCarbsListCalled)
        XCTAssertTrue(spy.doShowBolusListCalled)
        XCTAssertTrue(spy.doShowTrainingsListCalled)
        XCTAssertTrue(spy.doShowBasalsListCalled)
    }
    
    func testUpdateIntervals() throws {
        // Given
        let spy = HomeBusinessLogicSpy()
        sut.interactor = spy
        let mirror = HomeViewControllerMirror(viewController: sut)
        
        // When
        loadView()
        let view = try XCTUnwrap(mirror.carbsHistoryView)
        view.setLocalTimeFrame(.secondsPerHour)
        
        // Then
        XCTAssertTrue(view.localDateRange.duration ~~ view.localInterval + 2 * view.forwardTimeOffset)
        
        // When
        
        view.setLocalTimeFrame(12 * .secondsPerHour)
        
        // Then
        XCTAssertTrue(view.localDateRange.duration ~~ view.localInterval + 2 * view.forwardTimeOffset)
        
        // When
        
        view.setLocalTimeFrame(.secondsPerDay)
        
        // Then
        XCTAssertTrue(view.localDateRange.duration ~~ view.localInterval + view.forwardTimeOffset)
    }
    
    func testDisplayGlucoseData() throws {
        let mirror = HomeViewControllerMirror(viewController: sut)
        let worker = HomeGlucoseFormattingWorker()
        
        var randomInterval: Double { return Double.random(in: 100...2500) }
        
        func createEntry(_ value: Double) -> HomeGlucoseEntry {
            return HomeGlucoseEntry(value: value, date: Date().addingTimeInterval(-randomInterval), severity: .normal)
        }
        
        let glucoseValues =  [
            createEntry(146.2), createEntry(150.6), createEntry(147.8),
            createEntry(150.5), createEntry(149.2), createEntry(148.1)
        ]
        
        let strokeChartBasalValues = worker.formatEntries([InsulinEntry(amount: 0.0, date: Date(), type: .basal)])
        
        let viewModel = Home.GlucoseDataUpdate.ViewModel(
            glucoseValues: glucoseValues,
            basalDisplayMode: .onTop,
            basalValues: [],
            strokeChartBasalValues: strokeChartBasalValues,
            unit: User.current.settings.unit.label
        )
        
        func setupGlucoseChart(with entries: [HomeGlucoseEntry]) {
            mirror.glucoseChart?.setup(
                with: entries,
                basalDisplayMode: viewModel.basalDisplayMode,
                basalEntries: viewModel.basalValues,
                strokeChartEntries: viewModel.strokeChartBasalValues,
                unit: viewModel.unit
            )
        }

        //When
        loadView()
        setupGlucoseChart(with: glucoseValues)
        
        //Then
        XCTAssertTrue(mirror.glucoseChart?.leftLabelsView.labels.count == mirror.glucoseChart?.maxVerticalLinesCount)
        
        //When
        
        let glucoseValues1 =  [
            createEntry(148.2), createEntry(150.6), createEntry(149.8), createEntry(148.5), createEntry(149.7)
        ]
        
        setupGlucoseChart(with: glucoseValues1)
        
        //Then
        XCTAssertTrue(mirror.glucoseChart?.leftLabelsView.labels.count == 4)
        
        //When
        
        let glucoseValues2 =  [
            createEntry(149.2), createEntry(150.6), createEntry(149.8), createEntry(149.7), createEntry(149.6)
        ]
        
        setupGlucoseChart(with: glucoseValues2)
        
        //Then
        XCTAssertTrue(mirror.glucoseChart?.leftLabelsView.labels.count == 3)
        
        let glucoseValues3 =  [
            createEntry(150.2), createEntry(150.6), createEntry(150.8), createEntry(150.7), createEntry(150.6)
        ]
        
        setupGlucoseChart(with: glucoseValues3)
        
        //Then
        XCTAssertTrue(mirror.glucoseChart?.leftLabelsView.labels.count == 2)
        
        //When
        
        let glucoseValues4 =  [createEntry(150.0), createEntry(150.0), createEntry(150.0)]
        
        setupGlucoseChart(with: glucoseValues4)
        
        //Then
        XCTAssertTrue(mirror.glucoseChart?.leftLabelsView.labels.count == 3)
    }
}

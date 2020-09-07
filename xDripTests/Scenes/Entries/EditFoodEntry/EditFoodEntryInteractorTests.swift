//
//  EditFoodEntryInteractorTests.swift
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

final class EditFoodEntryInteractorTests: XCTestCase {
    // MARK: Subject under test
    
    var sut: EditFoodEntryInteractor!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupEditFoodEntryInteractor()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupEditFoodEntryInteractor() {
        sut = EditFoodEntryInteractor()
    }
    
    // MARK: Test doubles
    
    final class EditFoodEntryPresentationLogicSpy: EditFoodEntryPresentationLogic {
        var presentLoadCalled = false
        
        func presentLoad(response: EditFoodEntry.Load.Response) {
            presentLoadCalled = true
        }
    }
    
    final class EditFoodEntryRoutingLogicSpy: EditFoodEntryRoutingLogic {
        var dismissCalled = false
        
        func dismissScene() {
            dismissCalled = true
        }
    }
    
    // MARK: Tests
    
    func testDoLoadOnCreateMode() {
        // Given
        let spy = EditFoodEntryPresentationLogicSpy()
        sut.presenter = spy
        let request = EditFoodEntry.Load.Request()
        
        // When
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }
    
    func testDoLoadOnEditMode() {
        // Given
        let spy = EditFoodEntryPresentationLogicSpy()
        let request = EditFoodEntry.Load.Request()
        sut.trainingEntry = TrainingEntry(duration: 0.0, intensity: .default, date: Date())
        sut.presenter = spy
        
        // When
        sut.mode = .edit
        sut.doLoad(request: request)
        
        // Then
        XCTAssertTrue(spy.presentLoadCalled, "doLoad(request:) should ask the presenter to format the result")
    }

    func testDoCancel() {
        let spy = EditFoodEntryRoutingLogicSpy()
        sut.router = spy
        
        // When
        sut.doCancel(request: EditFoodEntry.Cancel.Request())
        
        // Then
        XCTAssertTrue(spy.dismissCalled)
    }
    
    func testTrainingEntrySaving() {
        // Given
        let guess = TrainingEntriesWorker.fetchAllTrainings().count + 1
        
        // When
        sut.doSave(request: EditFoodEntry.Save.Request())
        
        // Than
        let entries = TrainingEntriesWorker.fetchAllTrainings()
        
        XCTAssertTrue(guess == entries.count)
        
        guard let lastEntry = entries.last else {
            XCTFail("Cannot get the last entry")
            return
        }
        
        TrainingEntriesWorker.deleteEntry(lastEntry)
    }
}

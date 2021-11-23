//
//  CTreatmentTests.swift
//  xDripTests
//
//  Created by Dmitry on 14.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import XCTest
@testable import xDrip
import AKUtils

// swiftlint:disable function_body_length

final class CTreatmentTests: AbstractRealmTest {
    override func setUp() {
        super.setUp()
    }
    
    func testInit() throws {
        let сarbEntry = CarbEntry(amount: 1.1, foodType: "2.2", date: Date())
        let treatment = CTreatment(entry: сarbEntry, treatmentType: .carbs)
        let externalID = сarbEntry.externalID
        XCTAssertTrue(treatment.type == .carbs)
        XCTAssertTrue(treatment.uuid == externalID)
        XCTAssertTrue(treatment.treatmentID == CTreatment.getIDFromUUID(uuid: externalID))
        XCTAssertTrue(treatment.carbs == сarbEntry.amount)
        XCTAssertNil(treatment.insulin)
        XCTAssertNil(treatment.duration)
        XCTAssertNil(treatment.exerciseIntensity)
        XCTAssertNil(treatment.utcOffset)
        XCTAssertTrue(treatment.uuid == externalID)
        XCTAssertTrue(treatment.eventType == "Meal Bolus")
        XCTAssertTrue(treatment.insulinInjections == "[]")
        
        let entryDate = try XCTUnwrap(сarbEntry.date)
        XCTAssertTrue(treatment.timestamp == Int(entryDate.timeIntervalSince1970))
        XCTAssertTrue(treatment.enteredBy == Constants.Nightscout.appIdentifierName)
        XCTAssertTrue(treatment.foodType == "2.2")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        XCTAssertTrue(treatment.sysTime == dateFormatter.string(from: entryDate))
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        XCTAssertTrue(treatment.createdAt == dateFormatter.string(from: entryDate))
    }
    
    func testGetIDFromUUID() {
        let uuid = "80ab3740-7964-45e2-91df-a2afeed037a6"
        let treatmentID = CTreatment.getIDFromUUID(uuid: uuid)
        XCTAssertTrue(treatmentID.count <= 24)
        XCTAssertTrue(treatmentID == "80ab3740796445e291dfa2af")
    }
    
    func testParseTreatmentsToEntries() throws {
        let сarbEntry = CarbEntry(amount: 1.3, foodType: "1.2", date: Date())
        let bolusEntry = InsulinEntry(amount: 2.5, date: Date(), type: .bolus)
        let basalEntry = InsulinEntry(amount: 2.6, date: Date(), type: .basal)
        let trainingEntry = TrainingEntry(duration: 5.0, intensity: .high, date: Date())
        
        var сarbsHandlerCalled = false
        var bolusHandlerCalled = false
        var basalHandlerCalled = false
        var trainingHandlerCalled = false
        
        let treatments = [
            CTreatment(entry: сarbEntry, treatmentType: .carbs),
            CTreatment(entry: bolusEntry, treatmentType: .bolus),
            CTreatment(entry: basalEntry, treatmentType: .basal),
            CTreatment(entry: trainingEntry, treatmentType: .training)
        ]
        
        CarbEntriesWorker.carbsDataHandler = {
            сarbsHandlerCalled = true
        }
        
        InsulinEntriesWorker.bolusDataHandler = {
            bolusHandlerCalled = true
        }
        
        InsulinEntriesWorker.basalDataHandler = {
            basalHandlerCalled = true
        }
        
        TrainingEntriesWorker.trainingDataHandler = {
            trainingHandlerCalled = true
        }
        
        CTreatment.parseFollowerTreatmentsToEntries(treatments: treatments)
        
        let carbs = CarbEntriesWorker.fetchAllCarbEntries(mode: .follower)
        XCTAssertTrue(carbs.count == 1)
        let carb = try XCTUnwrap(carbs.first)
        XCTAssertTrue(carb.amount == сarbEntry.amount)
        
        let bolus = InsulinEntriesWorker.fetchAllBolusEntries(mode: .follower)
        XCTAssertTrue(bolus.count == 1)
        let entry = try XCTUnwrap(bolus.first)
        XCTAssertTrue(entry.amount == bolusEntry.amount)
        
        let basals = InsulinEntriesWorker.fetchAllBasalEntries(mode: .follower)
        XCTAssertTrue(basals.count == 1)
        let basal = try XCTUnwrap(basals.first)
        XCTAssertTrue(basal.amount == basalEntry.amount)
        
        let trainings = TrainingEntriesWorker.fetchAllTrainings(mode: .follower)
        XCTAssertTrue(trainings.count == 1)
        let training = try XCTUnwrap(trainings.first)
        XCTAssertTrue(training.amount == trainingEntry.amount)
        
        XCTAssertTrue(сarbsHandlerCalled)
        XCTAssertTrue(bolusHandlerCalled)
        XCTAssertTrue(basalHandlerCalled)
        XCTAssertTrue(trainingHandlerCalled)
        
        CarbEntriesWorker.deleteCarbsEntry(carb)
        InsulinEntriesWorker.deleteInsulinEntry(entry)
        InsulinEntriesWorker.deleteInsulinEntry(basal)
        TrainingEntriesWorker.deleteTrainingEntry(training)
    }
    
    func testGetDate() throws {
        let date = Date()
        let сarbEntry = CarbEntry(amount: 1.3, foodType: "1.2", date: date)
        let treatment = CTreatment(entry: сarbEntry, treatmentType: .carbs)
        
        CTreatment.parseFollowerTreatmentsToEntries(treatments: [treatment])
        
        let carbs = CarbEntriesWorker.fetchAllCarbEntries(mode: .follower)
        XCTAssertTrue(carbs.count == 1)
        let carb = try XCTUnwrap(carbs.first)
        let firstInterval = try XCTUnwrap(carb.date?.timeIntervalSince1970)
        let secondInterval = try XCTUnwrap(сarbEntry.date?.timeIntervalSince1970)
        XCTAssertTrue(firstInterval ~~ secondInterval)
    }
}

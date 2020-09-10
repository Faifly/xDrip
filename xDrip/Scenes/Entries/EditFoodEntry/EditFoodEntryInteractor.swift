//
//  EditFoodEntryInteractor.swift
//  xDrip
//
//  Created by Artem Kalmykov on 17.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol EditFoodEntryBusinessLogic {
    func doLoad(request: EditFoodEntry.Load.Request)
    func doCancel(request: EditFoodEntry.Cancel.Request)
    func doSave(request: EditFoodEntry.Save.Request)
}

protocol EditFoodEntryDataStore: AnyObject {
    var mode: EditFoodEntry.Mode { get set }
    var entryType: EditFoodEntry.EntryType? { get set }
    var carbEntry: CarbEntry? { get set }
    var insulinEntry: InsulinEntry? { get set }
    var trainingEntry: TrainingEntry? { get set }
}

final class EditFoodEntryInteractor: EditFoodEntryBusinessLogic, EditFoodEntryDataStore {
    private struct CarbInput {
        var amount = 0.0
        var foodType: String?
        var date = Date()
    }
    
    private struct InsulinInput {
        var amount = 0.0
        var date = Date()
    }
    
    private struct TrainingInput {
        var duration: TimeInterval = .secondsPerMinute
        var intensity: TrainingIntensity = .default
        var date = Date()
    }
    
    var presenter: EditFoodEntryPresentationLogic?
    var router: EditFoodEntryRoutingLogic?
    
    var mode: EditFoodEntry.Mode = .create
    var entryType: EditFoodEntry.EntryType?
    var carbEntry: CarbEntry?
    var insulinEntry: InsulinEntry?
    var trainingEntry: TrainingEntry?
    
    private var carbInput = CarbInput()
    private var insulinInput = InsulinInput()
    private var trainingInput = TrainingInput()
    
    // MARK: Do something
    
    func doLoad(request: EditFoodEntry.Load.Request) {
        if let carbEntry = carbEntry {
            carbInput.amount = carbEntry.amount
            carbInput.foodType = carbEntry.foodType
            carbInput.date = carbEntry.date ?? Date()
        }
        
        if let insulinEntry = insulinEntry {
            insulinInput.amount = insulinEntry.amount
            insulinInput.date = insulinEntry.date ?? Date()
        }
        
        if let trainingEntry = trainingEntry {
            trainingInput.duration = trainingEntry.duration
            trainingInput.intensity = trainingEntry.intensity
            trainingInput.date = trainingEntry.date ?? Date()
        }
        
        let response = EditFoodEntry.Load.Response(
            insulinEntry: insulinEntry,
            carbEntry: carbEntry,
            trainingEntry: trainingEntry,
            entryType: entryType ?? .food,
            textChangedHandler: handleTextChanged(_:_:),
            dateChangedHandler: handleDateChanged(_:_:),
            foodTypeChangedHandler: handleFoodTypeChanged(_:),
            trainingIntensityChangedHandler: handleIntensityChanged(_:),
            timeIntervalChangedHandler: handleTrainingDurationChanged(_:)
        )
        presenter?.presentLoad(response: response)
    }
    
    func doCancel(request: EditFoodEntry.Cancel.Request) {
        router?.dismissScene()
    }
    
    func doSave(request: EditFoodEntry.Save.Request) {
        if let insulinEntry = insulinEntry,
            (insulinEntry.amount !~ insulinInput.amount || insulinEntry.date != insulinInput.date) {
            insulinEntry.update(amount: insulinInput.amount, date: insulinInput.date)
        } else if insulinEntry == nil, insulinInput.amount !~ 0.0 {
            if entryType == .basal {
                InsulinEntriesWorker.addBasalEntry(amount: insulinInput.amount, date: insulinInput.date)
            } else {
                InsulinEntriesWorker.addBolusEntry(amount: insulinInput.amount, date: insulinInput.date)
            }
        }
        
        if let carbEntry = carbEntry,
            (carbEntry.amount !~ carbInput.amount ||
            carbEntry.date != carbInput.date ||
            carbEntry.foodType != carbInput.foodType) {
            carbEntry.update(amount: carbInput.amount, foodType: carbInput.foodType, date: carbInput.date)
        } else if carbEntry == nil, carbInput.amount !~ 0.0 {
            CarbEntriesWorker.addCarbEntry(amount: carbInput.amount, foodType: carbInput.foodType, date: carbInput.date)
        }
        
        if let trainingEntry = trainingEntry,
            (trainingEntry.duration !~ trainingInput.duration ||
            trainingEntry.date != trainingInput.date ||
            trainingEntry.intensity != trainingInput.intensity) {
            trainingEntry.update(duration: trainingInput.duration,
                                 intensity: trainingInput.intensity,
                                 date: trainingInput.date)
        } else if entryType == .training, trainingEntry == nil, trainingInput.duration !~ 0.0 {
            TrainingEntriesWorker.addTraining(duration: trainingInput.duration,
                                              intensity: trainingInput.intensity,
                                              date: trainingInput.date)
        }

        router?.dismissScene()
    }
    
    private func handleTextChanged(_ field: EditFoodEntry.Field, _ string: String?) {
        guard let stringValue = string?.replacingOccurrences(of: ",", with: "."),
            let value = Double(stringValue) else {
            return
        }
        
        switch field {
        case .carbsAmount: carbInput.amount = value
        case .insulinAmount: insulinInput.amount = value
        default: break
        }
    }
    
    private func handleDateChanged(_ field: EditFoodEntry.Field, _ date: Date) {
        switch field {
        case .carbsDate: carbInput.date = date
        case .insulinDate: insulinInput.date = date
        case .trainingDate: trainingInput.date = date
        default: break
        }
    }
    
    private func handleFoodTypeChanged(_ foodType: String?) {
        carbInput.foodType = foodType
    }
    
    private func handleIntensityChanged(_ intensity: TrainingIntensity) {
        trainingInput.intensity = intensity
    }
    
    private func handleTrainingDurationChanged(_ duration: TimeInterval) {
        trainingInput.duration = duration
    }
}

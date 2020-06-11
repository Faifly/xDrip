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
    var bolusEntry: BolusEntry? { get set }
}

final class EditFoodEntryInteractor: EditFoodEntryBusinessLogic, EditFoodEntryDataStore {
    private struct CarbInput {
        var amount = 0.0
        var foodType: String?
        var date = Date()
    }
    
    private struct BolusInput {
        var amount = 0.0
        var date = Date()
    }
    
    var presenter: EditFoodEntryPresentationLogic?
    var router: EditFoodEntryRoutingLogic?
    
    var mode: EditFoodEntry.Mode = .create
    var entryType: EditFoodEntry.EntryType?
    var carbEntry: CarbEntry?
    var bolusEntry: BolusEntry?
    
    private var carbInput = CarbInput()
    private var bolusInput = BolusInput()
    
    // MARK: Do something
    
    func doLoad(request: EditFoodEntry.Load.Request) {
        if let carbEntry = carbEntry {
            carbInput.amount = carbEntry.amount
            carbInput.foodType = carbEntry.foodType
            carbInput.date = carbEntry.date ?? Date()
        }
        
        if let bolusEntry = bolusEntry {
            bolusInput.amount = bolusEntry.amount
            bolusInput.date = bolusEntry.date ?? Date()
        }
        
        let response = EditFoodEntry.Load.Response(
            bolusEntry: bolusEntry,
            carbEntry: carbEntry,
            entryType: entryType ?? .food,
            textChangedHandler: handleTextChanged(_:_:),
            dateChangedHandler: handleDateChanged(_:_:),
            foodTypeChangedHandler: handleFoodTypeChanged(_:)
        )
        presenter?.presentLoad(response: response)
    }
    
    func doCancel(request: EditFoodEntry.Cancel.Request) {
        router?.dismissScene()
    }
    
    func doSave(request: EditFoodEntry.Save.Request) {
        if let bolusEntry = bolusEntry,
            (bolusEntry.amount !~ bolusInput.amount || bolusEntry.date != bolusInput.date) {
            bolusEntry.update(amount: bolusInput.amount, date: bolusInput.date)
        } else if bolusEntry == nil, bolusInput.amount !~ 0.0 {
            FoodEntriesWorker.addBolusEntry(amount: bolusInput.amount, date: bolusInput.date)
        }
        
        if let carbEntry = carbEntry,
            (carbEntry.amount !~ carbInput.amount ||
            carbEntry.date != carbInput.date ||
            carbEntry.foodType != carbInput.foodType) {
            carbEntry.update(amount: carbInput.amount, foodType: carbInput.foodType, date: carbInput.date)
        } else if carbEntry == nil, carbInput.amount !~ 0.0 {
            FoodEntriesWorker.addCarbEntry(amount: carbInput.amount, foodType: carbInput.foodType, date: carbInput.date)
        }

        router?.dismissScene()
    }
    
    private func handleTextChanged(_ field: EditFoodEntry.Field, _ string: String?) {
        guard let stringValue = string, let value = Double(stringValue) else {
            return
        }
        
        switch field {
        case .carbsAmount: carbInput.amount = value
        case .bolusAmount: bolusInput.amount = value
        default: break
        }
    }
    
    private func handleDateChanged(_ field: EditFoodEntry.Field, _ date: Date) {
        switch field {
        case .carbsDate: carbInput.date = date
        case .bolusDate: bolusInput.date = date
        default: break
        }
    }
    
    private func handleFoodTypeChanged(_ foodType: String?) {
        carbInput.foodType = foodType
    }
}

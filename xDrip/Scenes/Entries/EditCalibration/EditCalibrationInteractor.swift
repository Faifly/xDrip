//
//  EditCalibrationInteractor.swift
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

protocol EditCalibrationBusinessLogic {
    func doLoad(request: EditCalibration.Load.Request)
    func doSave(request: EditCalibration.Save.Request)
    func doDismiss(request: EditCalibration.Dismiss.Request)
}

protocol EditCalibrationDataStore: AnyObject {
}

final class EditCalibrationInteractor: EditCalibrationBusinessLogic, EditCalibrationDataStore {
    struct Input {
        var value: String?
        var date = Date()
    }
    
    var presenter: EditCalibrationPresentationLogic?
    var router: EditCalibrationRoutingLogic?
    
    private let statusWorker: EditCalibrationStatusWorkerLogic
    private let savingWorker: EditCalibrationSavingWorkerLogic
    
    private var firstInput = Input()
    private var secondInput = Input()
    
    init() {
        statusWorker = EditCalibrationStatusWorker()
        savingWorker = EditCalibrationSavingWorker()
    }
    
    // MARK: Do something
    
    func doLoad(request: EditCalibration.Load.Request) {
        let response = EditCalibration.Load.Response(
            hasInitialCalibrations: statusWorker.hasInitialCalibrations,
            datePickerValueChanged: handleDatePickerValueChanged(_:_:),
            glucosePickerValueChanged: handleGlucosePickerValueChanged(_:_:)
        )
        presenter?.presentLoad(response: response)
    }
    
    func doDismiss(request: EditCalibration.Dismiss.Request) {
        router?.dismissScene()
    }
    
    func doSave(request: EditCalibration.Save.Request) {
        do {
            try savingWorker.saveInput(
                entry1: firstInput.value,
                entry2: secondInput.value,
                date1: firstInput.date,
                date2: secondInput.date
            )
        } catch {
            router?.showError(error.localizedDescription)
            return
        }
        
        router?.showSuccessAndDismiss()
    }
    
    private func handleDatePickerValueChanged(_ field: EditCalibration.Field, _ date: Date) {
        switch field {
        case .firstInput: firstInput.date = date
        case .secondInput: secondInput.date = date
        }
    }
    
    private func handleGlucosePickerValueChanged(_ field: EditCalibration.Field, _ value: String?) {
        switch field {
        case .firstInput: firstInput.value = value
        case .secondInput: secondInput.value = value
        }
    }
}

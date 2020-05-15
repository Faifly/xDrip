//
//  EditCalibrationStatusWorker.swift
//  xDrip
//
//  Created by Artem Kalmykov on 15.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol EditCalibrationStatusWorkerLogic {
    var hasInitialCalibrations: Bool { get }
}

final class EditCalibrationStatusWorker: EditCalibrationStatusWorkerLogic {
    var hasInitialCalibrations: Bool {
        return Calibration.allForCurrentSensor.count > 1
    }
}

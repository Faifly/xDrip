//
//  UploadRequest.swift
//  xDrip
//
//  Created by Artem Kalmykov on 10.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

struct UploadRequest {
    let request: URLRequest
    let itemIDs: [String]
    var type: UploadRequestType
}

enum UploadRequestType {
    case postGlucoseReading
    case modifyGlucoseReading
    case deleteGlucoseReading
    case postCalibration
    case deleteCalibration
    case postCarbs
    case modifyCarbs
    case deleteCarbs
    case postBolus
    case modifyBolus
    case deleteBolus
    case postBasal
    case modifyBasal
    case deleteBasal
    case postTraining
    case modifyTraining
    case deleteTraining
}

enum RequestType {
    case post
    case modify
    case delete
}

extension UploadRequest: Equatable {
    static func == (lhs: UploadRequest, rhs: UploadRequest) -> Bool {
        return lhs.itemIDs == rhs.itemIDs
    }
}

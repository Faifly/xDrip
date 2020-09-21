//
//  TreatmentType.swift
//  xDrip
//
//  Created by Dmitry on 11.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol TreatmentEntryProtocol {
    var amount: Double { get }
    var date: Date? { get }
    var externalID: String { get }
    var cloudUploadStatus: CloudUploadStatus { get }
    var exerciseIntensity: Int? { get set }
}

extension TreatmentEntryProtocol {
    var exerciseIntensity: Int? {
        get { return nil }
        set { exerciseIntensity = newValue }
    }
}

enum TreatmentType: String {
    case carbs
    case bolus
    case basal
    case training
    
    func getUploadRequestTypeFor(requestType: RequestType) -> UploadRequestType {
        var postrequestType: UploadRequestType
        var modifyRequestType: UploadRequestType
        var deleteRequestType: UploadRequestType
        
        switch self {
        case .carbs:
            postrequestType = .postCarbs
            modifyRequestType = .modifyCarbs
            deleteRequestType = .deleteCarbs
        case .bolus:
            postrequestType = .postBolus
            modifyRequestType = .modifyBolus
            deleteRequestType = .deleteBolus
        case .basal:
            postrequestType = .postBasal
            modifyRequestType = .modifyBasal
            deleteRequestType = .deleteBasal
        case .training:
            postrequestType = .postTraining
            modifyRequestType = .modifyTraining
            deleteRequestType = .deleteTraining
        }
        
        switch requestType {
        case .post:
            return postrequestType
        case .modify:
            return modifyRequestType
        case .delete:
            return deleteRequestType
        }
    }
}

//
//  CTreatment.swift
//  xDrip
//
//  Created by Dmitry on 31.08.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol TreatmentEntryProtocol {
    var amount: Double { get }
    var date: Date? { get }
    var externalID: String? { get }
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

struct CTreatment: Codable {
    var type: TreatmentType?
    let treatmentID: String?
    let carbs: Double?
    let duration: Double?
    let exerciseIntensity: String?
    let eventType: String?
    let insulin: Double?
    let uuid: String?
    let createdAt: String?
    let sysTime: String?
    let utcOffset: Int?
    let timestamp: Int?
    let enteredBy: String?
    let insulinInjections: String?
    let foodType: String?
    
    enum CodingKeys: String, CodingKey {
        case treatmentID = "_id"
        case carbs
        case eventType
        case insulin
        case uuid
        case createdAt = "created_at"
        case sysTime
        case utcOffset
        case timestamp
        case enteredBy
        case insulinInjections
        case foodType
        case duration
        case exerciseIntensity
    }
    
    init(entry: TreatmentEntryProtocol, treatmentType: TreatmentType) {
        type = treatmentType
        
        uuid = entry.externalID
        treatmentID = CTreatment.getIDFromUUID(uuid: uuid)
        
        switch treatmentType {
        case .carbs:
            carbs = entry.amount
            insulin = nil
            duration = nil
            exerciseIntensity = nil
        case .bolus, .basal:
            carbs = nil
            insulin = entry.amount
            duration = nil
            exerciseIntensity = nil
        case .training:
            carbs = nil
            insulin = nil
            duration = entry.amount / .secondsPerMinute
            
            if let intensityValue = entry.exerciseIntensity,
               let intensityString = TrainingIntensity(rawValue: intensityValue)?.paramValue() {
                exerciseIntensity = intensityString
            } else {
                exerciseIntensity = nil
            }
        }
        
        eventType = treatmentType.rawValue.capitalized
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        sysTime = dateFormatter.string(from: entry.date ?? Date())
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        createdAt = dateFormatter.string(from: entry.date ?? Date())
        
        utcOffset = nil
        timestamp = Int((entry.date ?? Date()).timeIntervalSince1970)
        enteredBy = "xdrip iOS"
        insulinInjections = "[]"
        
        if treatmentType == .carbs, let carbEntry = entry as? CarbEntry {
            foodType = carbEntry.foodType
        } else {
            foodType = nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        treatmentID = try? container.decode(String.self, forKey: .treatmentID)
        carbs = try? container.decode(Double.self, forKey: .carbs)
        eventType = try? container.decode(String.self, forKey: .eventType)
        insulin = try? container.decode(Double.self, forKey: .insulin)
        uuid = try? container.decode(String.self, forKey: .uuid)
        createdAt = try? container.decode(String.self, forKey: .createdAt)
        sysTime = try? container.decode(String.self, forKey: .sysTime)
        utcOffset = try? container.decode(Int.self, forKey: .utcOffset)
        timestamp = try? container.decode(Int.self, forKey: .timestamp)
        enteredBy = try? container.decode(String.self, forKey: .enteredBy)
        insulinInjections = try? container.decode(String.self, forKey: .insulinInjections)
        foodType = try? container.decode(String.self, forKey: .foodType)
        duration = try? container.decode(Double.self, forKey: .duration)
        exerciseIntensity = try? container.decode(String.self, forKey: .exerciseIntensity)
        
        switch eventType?.lowercased() {
        case TreatmentType.carbs.rawValue.lowercased():
            type = .carbs
        case TreatmentType.bolus.rawValue.lowercased():
            type = .bolus
        case TreatmentType.basal.rawValue.lowercased():
            type = .basal
        case TreatmentType.training.rawValue.lowercased():
            type = .training
        default:
            type = .carbs
        }
    }
    
    static func getIDFromUUID(uuid: String?) -> String {
        guard let externalID = uuid else { return "" }
        if externalID.count <= 24 {
            return externalID
        } else {
            let str = externalID.replacingOccurrences(of: "-", with: "")
            let endIndex = str.index(str.startIndex, offsetBy: 24)
            let subStr = str[..<endIndex]
            return String(subStr)
        }
    }
    
    static func parseTreatmentsToEntries(treatments: [CTreatment]) {
        guard !treatments.isEmpty else { return }
        let allCarbs = CarbEntriesWorker.fetchAllCarbEntries()
        let allBolus = InsulinEntriesWorker.fetchAllBolusEntries()
        let allBasal = InsulinEntriesWorker.fetchAllBasalEntries()
        let allTrainings = TrainingEntriesWorker.fetchAllTrainings()
        
        for treatment in treatments {
            let treatmentDate = CTreatment.getTreatmentDate(treatment)
            
            switch treatment.type {
            case .carbs:
                if !allCarbs.contains(where: { $0.externalID == treatment.uuid }), let amount = treatment.carbs {
                    CarbEntriesWorker.addCarbEntry(amount: amount,
                                                   foodType: treatment.foodType,
                                                   date: treatmentDate,
                                                   externalID: treatment.uuid)
                }
            case .bolus:
                if !allBolus.contains(where: { $0.externalID == treatment.uuid }), let amount = treatment.insulin {
                    InsulinEntriesWorker.addBolusEntry(amount: amount, date: treatmentDate, externalID: treatment.uuid)
                }
            case .basal:
                if !allBasal.contains(where: { $0.externalID == treatment.uuid }), let amount = treatment.insulin {
                    InsulinEntriesWorker.addBasalEntry(amount: amount, date: treatmentDate, externalID: treatment.uuid)
                }
            case .training:
                if !allTrainings.contains(where: { $0.externalID == treatment.uuid }),
                    let duration = treatment.duration,
                    let intensity = treatment.exerciseIntensity {
                    TrainingEntriesWorker.addTraining(duration: duration * .secondsPerMinute,
                                                      intensity: TrainingIntensity.getValue(paramValue: intensity),
                                                      date: treatmentDate,
                                                      externalID: treatment.uuid)
                }
            default:
                break
            }
        }
    }
    
    private static func getTreatmentDate(_ treatment: CTreatment) -> Date {
        let treatmentDate: Date
        if let sysTime = treatment.sysTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            treatmentDate = dateFormatter.date(from: sysTime) ?? Date()
        } else if let timestamp = treatment.timestamp {
            treatmentDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let createdAt = treatment.createdAt {
                treatmentDate = dateFormatter.date(from: createdAt) ?? Date()
            } else {
                treatmentDate = Date()
            }
        }
        return treatmentDate
    }
}

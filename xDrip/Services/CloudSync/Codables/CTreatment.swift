//
//  CTreatment.swift
//  xDrip
//
//  Created by Dmitry on 31.08.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

// swiftlint:disable function_body_length

struct CTreatment: Codable {
    var type: TreatmentType?
    let treatmentID: String?
    let carbs: Double?
    let duration: Double?
    let absorptionTime: Double?
    let exerciseIntensity: String?
    let eventType: String?
    let insulin: Double?
    let uuid: String?
    let createdAt: String?
    let sysTime: String?
    let utcOffset: Int?
    let timestamp: Int?
    let timestampString: String?
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
        case absorptionTime
    }
    
    init(entry: TreatmentEntryProtocol, treatmentType: TreatmentType) {
        type = treatmentType
        
        uuid = entry.externalID
        treatmentID = CTreatment.getIDFromUUID(uuid: uuid)
        
        switch treatmentType {
        case .carbs:
            let defaultAbsorptionTime = User.current.settings.carbsAbsorptionRate
            absorptionTime = (entry.treatmentAbsorptionTime ?? defaultAbsorptionTime) / .secondsPerMinute
            carbs = entry.amount
            insulin = nil
            duration = nil
            exerciseIntensity = nil
        case .bolus:
            let defaultAbsorptionTime = User.current.settings.insulinActionTime
            absorptionTime = (entry.treatmentAbsorptionTime ?? defaultAbsorptionTime) / .secondsPerMinute
            carbs = nil
            insulin = entry.amount
            duration = nil
            exerciseIntensity = nil
        case .basal:
            absorptionTime = nil
            carbs = nil
            insulin = entry.amount
            duration = nil
            exerciseIntensity = nil
        case .training:
            absorptionTime = nil
            carbs = nil
            insulin = nil
            duration = entry.amount / .secondsPerMinute
            
            if let intensityValue = entry.exerciseIntensity,
               let intensityString = TrainingIntensity(rawValue: intensityValue)?.paramValue {
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
        enteredBy = Constants.Nightscout.appIdentifierName
        insulinInjections = "[]"
        timestampString = createdAt
        
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
        timestampString = try? container.decode(String.self, forKey: .timestamp)
        enteredBy = try? container.decode(String.self, forKey: .enteredBy)
        insulinInjections = try? container.decode(String.self, forKey: .insulinInjections)
        foodType = try? container.decode(String.self, forKey: .foodType)
        duration = try? container.decode(Double.self, forKey: .duration)
        exerciseIntensity = try? container.decode(String.self, forKey: .exerciseIntensity)
        absorptionTime = try? container.decode(Double.self, forKey: .absorptionTime)
        
        if carbs != nil {
            type = .carbs
        } else if insulin != nil {
            switch eventType?.lowercased() {
            case TreatmentType.basal.rawValue.lowercased():
                type = .basal
            default:
                type = .bolus
            }
        } else {
            switch eventType?.lowercased() {
            case TreatmentType.training.rawValue.lowercased():
                type = .training
            default:
                break
            }
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
        //Server doesn't accept ids with length more than 24 symbols
    }
    
    static func parseFollowerTreatmentsToEntries(treatments: [CTreatment]) {
        guard !treatments.isEmpty else { return }
        
        var allObjects: [Object] = []
        var types: [TreatmentType?] = []
        
        for treatment in treatments {
            if let object = createRealmObjectFrom(treatment: treatment) {
                allObjects.append(object)
                if !types.contains(treatment.type) {
                    types.append(treatment.type)
                }
            }
        }
        
        let realm = Realm.shared
        realm.safeWrite {
            realm.add(allObjects, update: .all)
        }
        
        let datePredicate = NSPredicate.earlierThan(
            date: Date().addingTimeInterval(-(Constants.observableTreatmentsPeriod)))
        
        CarbEntriesWorker.deleteAllEntries(mode: .follower, filter: datePredicate)
        
        if types.contains(.carbs) { CarbEntriesWorker.deleteAllEntries(mode: .follower, filter: datePredicate) }
        if types.contains(.bolus) { InsulinEntriesWorker.deleteAllEntries(mode: .follower, filter: datePredicate) }
        if types.contains(.basal) { InsulinEntriesWorker.deleteAllEntries(mode: .follower, filter: datePredicate) }
        if types.contains(.training) { TrainingEntriesWorker.deleteAllEntries(mode: .follower, filter: datePredicate) }
    }
    
    private static func createRealmObjectFrom(treatment: CTreatment) -> Object? {
        var object: AbstractEntry?
        
        guard let treatmentDate = treatment.date,
              let externalID = treatment.identificator
        else { return nil }
       
        var absorptionDuration: TimeInterval?
        if let time = treatment.absorptionTime {
            absorptionDuration = time * .secondsPerMinute
        }
        
        let followerID = externalID.hasSuffix(Constants.followerSuffix) ?
                         externalID :
                         externalID + Constants.followerSuffix
        
        switch treatment.type {
        case .carbs:
            if let amount = treatment.carbs {
                object = CarbEntry(amount: amount,
                                   foodType: treatment.foodType,
                                   date: treatmentDate,
                                   externalID: followerID,
                                   absorptionDuration: absorptionDuration)
            }
        case .bolus:
            if let amount = treatment.insulin {
                object = InsulinEntry(amount: amount,
                                      date: treatmentDate,
                                      type: .bolus,
                                      externalID: followerID,
                                      absorptionDuration: absorptionDuration)
            }
        case .basal:
            if let amount = treatment.insulin {
                object = InsulinEntry(amount: amount,
                                      date: treatmentDate,
                                      type: .basal,
                                      externalID: followerID)
            }
        case .training:
            if let duration = treatment.duration, let intensity = treatment.exerciseIntensity {
                object = TrainingEntry(duration: duration * .secondsPerMinute,
                                       intensity: TrainingIntensity(paramValue: intensity),
                                       date: treatmentDate,
                                       externalID: followerID)
            }
        default:
            break
        }
        
        object?.deviceMode = .follower
        
        return object
    }
    
    private var date: Date? {
        var treatmentDate: Date?
        let dateFormatter = DateFormatter()
        
        let dateFormats = ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ss'Z'"]
        let dateStrings = [sysTime, createdAt, timestampString]
        
        for dateFormat in dateFormats {
            for dateString in dateStrings {
                if let dateString = dateString, treatmentDate == nil {
                    dateFormatter.dateFormat = dateFormat
                    treatmentDate = dateFormatter.date(from: dateString)
                }
            }
        }
        
        if let timestamp = timestamp, treatmentDate == nil {
            treatmentDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
        }
      
        return treatmentDate
    }

    private var identificator: String? {
        return uuid ?? treatmentID
    }
}

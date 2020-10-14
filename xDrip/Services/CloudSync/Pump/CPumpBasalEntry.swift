//
//  CPumpBasalEntry.swift
//  xDrip
//
//  Created by Artem Kalmykov on 01.10.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name

struct CPumpBasalEntry: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rate
        case timestamp
        case createdAt = "created_at"
        case absolute
        case eventType
        case enteredBy
        case temp
        case duration
        case amount
    }
    
    let id: String?
    let rate: Double?
    let timestamp: String?
    let createdAt: String?
    let absolute: Double?
    let eventType: String?
    let enteredBy: String?
    let temp: String?
    let duration: Double?
    let amount: Double?
}

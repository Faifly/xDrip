//
//  BasalChartBasalEntry.swift
//  xDrip
//
//  Created by Ivan Skoryk on 22.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol BasalChartBasalEntry {
    var value: Double { get }
    var date: Date { get }
}

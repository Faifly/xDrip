//
//  GlucoseCurrentInfoEntry.swift
//  xDrip
//
//  Created by Dmitry on 6/18/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import UIKit

protocol GlucoseCurrentInfoEntry {
    var glucoseIntValue: String { get }
    var glucoseDecimalValue: String { get }
    var slopeValue: String { get }
    var lastScanDate: String { get }
    var difValue: String { get }
    var severityColor: UIColor? { get }
}

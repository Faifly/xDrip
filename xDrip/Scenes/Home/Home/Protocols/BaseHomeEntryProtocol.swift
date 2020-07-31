//
//  BaseHomeEntryProtocol.swift
//  xDrip
//
//  Created by Dmitry on 6/26/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import UIKit

protocol BaseHomeEntryProtocol {
    var title: String { get }
    var entries: [BaseChartEntry] { get }
    var unit: String { get }
    var color: UIColor { get }
}

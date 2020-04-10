//
//  GlucoseUnit.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

enum GlucoseUnit: Int, CaseIterable {
    case mgDl
    case mmolL
    
    private static let convertionScale: Double = 0.0554994394556615
    
    static var `default`: GlucoseUnit {
        return .mgDl
    }
    
    func convertToAnother(_ value: Double) -> Double {
        switch self {
        case .mgDl: return value * GlucoseUnit.convertionScale
        case .mmolL: return value / GlucoseUnit.convertionScale
        }
    }
}

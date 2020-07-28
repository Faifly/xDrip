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
    
    static func convertToDefault(_ value: Double) -> Double {
        let current = User.current.settings.unit
        switch current {
        case .mgDl: return value
        case .mmolL: return current.convertToAnother(value)
        }
    }
    
    static func convertFromDefault(_ value: Double) -> Double {
        let current = User.current.settings.unit
        switch current {
        case .mgDl: return value
        case .mmolL: return GlucoseUnit.mgDl.convertToAnother(value)
        }
    }
    
    var label: String {
        switch self {
        case .mgDl: return "settings_units_mgdl".localized
        case .mmolL: return "settings_units_mmolL".localized
        }
    }
    
    var minMax: Range<Double> {
        switch self {
        case .mgDl: return 0.0 ..< 400.0
        case .mmolL: return 0.0 ..< 20.0
        }
    }
    
    var changeRange: Range<Double> {
        switch self {
        case .mgDl: return 0.0 ..< 30.0
        case .mmolL: return 0.0 ..< 1.7
        }
    }
    
    var pickerStep: Double {
        switch self {
        case .mgDl: return 1.0
        case .mmolL: return 0.1
        }
    }
}

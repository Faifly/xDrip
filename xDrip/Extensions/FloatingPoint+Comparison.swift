//
//  FloatingPoint+Comparison.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

infix operator ~ : ComparisonPrecedence
infix operator !~ : ComparisonPrecedence
infix operator ~~ : ComparisonPrecedence
infix operator !~~ : ComparisonPrecedence

extension Double {
    static func ~(lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) <= Double(Float32.ulpOfOne)
    }
}

extension Double {
    static func !~(lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) > Double(Float32.ulpOfOne)
    }
}

extension Double {
    static func ~~(lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) < 1.0
    }
}

extension Double {
    static func !~~(lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) > 1.0
    }
}

extension CGFloat{
    static func ~(lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) <= .ulpOfOne * 1000.0
    }
}

extension CGFloat {
    static func !~(lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) > .ulpOfOne * 1000.0
    }
}

extension CGFloat {
    static func ~~(lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) < 1.0
    }
}

extension CGFloat {
    static func !~~(lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) > 1.0
    }
}

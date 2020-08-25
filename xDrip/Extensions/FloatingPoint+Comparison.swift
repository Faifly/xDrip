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
infix operator ~~<: ComparisonPrecedence

extension Double {
    static func ~ (lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) <= Double(Float32.ulpOfOne)
    }
}

extension Double {
    static func !~ (lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) > Double(Float32.ulpOfOne)
    }
}

extension Double {
    static func ~~ (lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) < 1.0
    }
}

extension Double {
    static func !~~ (lhs: Double, rhs: Double) -> Bool {
        return abs(lhs - rhs) > 1.0
    }
}

extension Double {
    static func ~~< (lhs: Double, rhs: Double) -> Bool {
        return lhs.rounded(to: 2) < rhs.rounded(to: 2)
    }
}

func ~ (lhs: Double?, rhs: Double) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs ~ rhs
}

extension CGFloat {
    static func ~ (lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) <= .ulpOfOne * 1000.0
    }
}

extension CGFloat {
    static func !~ (lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) > .ulpOfOne * 1000.0
    }
}

extension CGFloat {
    static func ~~ (lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) < 1.0
    }
}

extension CGFloat {
    static func !~~ (lhs: CGFloat, rhs: CGFloat) -> Bool {
        return abs(lhs - rhs) > 1.0
    }
}

extension Date {
    static func ~~ (lhs: Date, rhs: Date) -> Bool {
        return lhs.timeIntervalSince1970 ~~ rhs.timeIntervalSince1970
    }
}

func ~~ (lhs: Date?, rhs: Date?) -> Bool {
    guard let lhs = lhs, let rhs = rhs else { return false }
    return lhs.timeIntervalSince1970 ~~ rhs.timeIntervalSince1970
}

func ~~ (lhs: Date, rhs: Date?) -> Bool {
    guard let rhs = rhs else { return false }
    return lhs.timeIntervalSince1970 ~~ rhs.timeIntervalSince1970
}

func ~~ (lhs: Date?, rhs: Date) -> Bool {
    guard let lhs = lhs else { return false }
    return lhs.timeIntervalSince1970 ~~ rhs.timeIntervalSince1970
}

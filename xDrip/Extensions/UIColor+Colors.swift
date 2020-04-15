//
//  UIColor+Colors.swift
//  xDrip
//
//  Created by Ivan Skoryk on 23.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

extension UIColor {
    enum Colors: String {
        case tabBarBackground
        case tabBarBlue
        case tabBarGray
        case tabBarGreen
        case tabBarOrange
        case tabBarRed
        case borderColor
        case chartGridLineColor
        case chartTextColor
        case detailTextColor
    }
    
    static var tabBarBackgroundColor: UIColor {
        return UIColor(named: Colors.tabBarBackground.rawValue)!
    }
    
    static var tabBarBlueColor: UIColor {
        return UIColor(named: Colors.tabBarBlue.rawValue)!
    }
    
    static var tabBarGrayColor: UIColor {
        return UIColor(named: Colors.tabBarGray.rawValue)!
    }
    
    static var tabBarGreenColor: UIColor {
        return UIColor(named: Colors.tabBarGreen.rawValue)!
    }
    
    static var tabBarOrangeColor: UIColor {
        return UIColor(named: Colors.tabBarOrange.rawValue)!
    }
    
    static var tabBarRedColor: UIColor {
        return UIColor(named: Colors.tabBarRed.rawValue)!
    }
    
    static var borderColor: UIColor {
        return UIColor(named: Colors.borderColor.rawValue)!
    }
    
    static var chartGridLineColor: UIColor {
        return UIColor(named: Colors.chartGridLineColor.rawValue)!
    }
    
    static var chartTextColor: UIColor {
        return UIColor(named: Colors.chartTextColor.rawValue)!
    }
    
    static var detailTextColor: UIColor {
        return UIColor(named: Colors.detailTextColor.rawValue)!
    }
}

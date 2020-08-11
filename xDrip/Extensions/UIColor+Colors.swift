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
        case background1 = "background_1"
        case background2 = "background_2"
        case background3 = "background_3"
        case tabBarBackground
        case tabBarBlue
        case tabBarGray
        case tabBarGreen
        case tabBarOrange
        case tabBarRed
        case borderColor
        case chartGridLineColor
        case chartTextColor
        case lowEmphasisText
        case mediumEmphasisText
        case highEmphasisText
        case chartValueNormal
        case chartValueAbnormal
        case chartValueCritical
        case chartSliderBackground
        case chartSelectionLine
        case customBlue
        case diffTextColor
        case lastScanDateTextColor
        case chartButtonTextColor
        case chartButtonHighlitedTextColor
        case statsChartSelection
        case bolusChartEntry
        case carbsChartEntry
        case dimView
    }
    
    static var background1: UIColor {
        return color(withName: Colors.background1.rawValue)
    }
    
    static var background2: UIColor {
        return color(withName: Colors.background2.rawValue)
    }
    
    static var background3: UIColor {
        return color(withName: Colors.background3.rawValue)
    }
    
    static var tabBarBackgroundColor: UIColor {
        return color(withName: Colors.tabBarBackground.rawValue)
    }
    
    static var tabBarBlueColor: UIColor {
        return color(withName: Colors.tabBarBlue.rawValue)
    }
    
    static var tabBarGrayColor: UIColor {
        return color(withName: Colors.tabBarGray.rawValue)
    }
    
    static var tabBarGreenColor: UIColor {
        return color(withName: Colors.tabBarGreen.rawValue)
    }
    
    static var tabBarOrangeColor: UIColor {
        return color(withName: Colors.tabBarOrange.rawValue)
    }
    
    static var tabBarRedColor: UIColor {
        return color(withName: Colors.tabBarRed.rawValue)
    }
    
    static var borderColor: UIColor {
        return color(withName: Colors.borderColor.rawValue)
    }
    
    static var chartGridLineColor: UIColor {
        return color(withName: Colors.chartGridLineColor.rawValue)
    }
    
    static var chartTextColor: UIColor {
        return color(withName: Colors.chartTextColor.rawValue)
    }
    
    static var lowEmphasisText: UIColor {
        return color(withName: Colors.lowEmphasisText.rawValue)
    }
    
    static var mediumEmphasisText: UIColor {
        return color(withName: Colors.mediumEmphasisText.rawValue)
    }
    
    static var highEmphasisText: UIColor {
        return color(withName: Colors.highEmphasisText.rawValue)
    }
    
    static var chartValueNormal: UIColor {
        return color(withName: Colors.chartValueNormal.rawValue)
    }
    
    static var chartValueAbnormal: UIColor {
        return color(withName: Colors.chartValueAbnormal.rawValue)
    }
    
    static var chartValueCritical: UIColor {
        return color(withName: Colors.chartValueCritical.rawValue)
    }
    
    static var chartSliderBackground: UIColor {
        return color(withName: Colors.chartSliderBackground.rawValue)
    }
    
    static var chartSelectionLine: UIColor {
        return color(withName: Colors.chartSelectionLine.rawValue)
    }
    
    static var customBlue: UIColor {
        return color(withName: Colors.customBlue.rawValue)
    }
    
    static var diffTextColor: UIColor {
        return .chartValueNormal
    }
    
    static var lastScanDateTextColor: UIColor {
        return color(withName: Colors.lastScanDateTextColor.rawValue)
    }
    
    static var chartButtonTextColor: UIColor {
        return color(withName: Colors.chartButtonTextColor.rawValue)
    }
    
    static var chartButtonHighlitedTextColor: UIColor {
          return color(withName: Colors.chartButtonHighlitedTextColor.rawValue)
      }
    
    static var statsChartSelection: UIColor {
        return color(withName: Colors.statsChartSelection.rawValue)
    }
    
    static var bolusChartEntry: UIColor {
        return color(withName: Colors.bolusChartEntry.rawValue)
    }
    
    static var carbsChartEntry: UIColor {
        return color(withName: Colors.carbsChartEntry.rawValue)
    }
    
    static var dimView: UIColor {
        return color(withName: Colors.dimView.rawValue)
    }
    
    private static func color(withName name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            fatalError("No color with name: \(name)")
        }
        return color
    }
    
    static func colorForSeverityLevel(_ level: GlucoseChartSeverityLevel) -> UIColor {
        switch level {
        case .normal: return .chartValueNormal
        case .abnormal: return .chartValueAbnormal
        case .critical: return .chartValueCritical
        }
    }
}

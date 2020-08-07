//
//  GlucoseChartProvider.swift
//  xDrip
//
//  Created by Artem Kalmykov on 16.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import AKUtils

protocol GlucoseChartProvider: AnyObject {
    var dateInterval: DateInterval { get }
    var yRange: ClosedRange<Double> { get }
    var glucoseEntries: [GlucoseChartGlucoseEntry] { get }
    var timeInterval: TimeInterval { get set }
    var yInterval: Double { get set }
    var pixelsPerSecond: Double { get set }
    var pixelsPerValue: Double { get set }
    var insets: UIEdgeInsets { get }
    var circleSide: CGFloat { get }
    
    var minDate: TimeInterval { get set }
    var maxDate: TimeInterval { get set }
    
    func drawGlucoseChart()
}

extension GlucoseChartProvider where Self: UIView {
    func drawGlucoseChart() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        calculateValues()
        
        context.setLineWidth(0.0)
        
        for entry in glucoseEntries {
            let centerX = CGFloat((entry.date.timeIntervalSince1970 - minDate) * pixelsPerSecond) + insets.left
            let centerY = CGFloat((yRange.upperBound - entry.value) * pixelsPerValue) + insets.top
            let circleRect = CGRect(
                x: centerX - circleSide / 2.0,
                y: centerY - circleSide / 2.0,
                width: circleSide,
                height: circleSide
            )
    
            let color = UIColor.colorForSeverityLevel(entry.severity)
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: circleRect)
        }
    }
    
    private func calculateValues() {
        minDate = dateInterval.start.timeIntervalSince1970
        maxDate = dateInterval.end.timeIntervalSince1970
        timeInterval = maxDate - minDate
        pixelsPerSecond = Double(bounds.width - insets.left - insets.right) / timeInterval
        yInterval = Double(bounds.height - insets.bottom - insets.top)
        pixelsPerValue = yInterval / (yRange.upperBound - yRange.lowerBound)
    }
}

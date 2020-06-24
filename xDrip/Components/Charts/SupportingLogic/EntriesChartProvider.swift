//
//  EntriesChartProvider.swift
//  xDrip
//
//  Created by Dmitry on 6/23/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol EntriesChartProvider {
    var dateInterval: DateInterval { get }
    var yRange: ClosedRange<Double> { get }
    var entries: [GlucoseChartGlucoseEntry] { get }
    var insets: UIEdgeInsets { get }
    var circleSide: CGFloat { get }
    
    func drawGlucoseChart()
}

extension EntriesChartProvider where Self: UIView {
    func drawGlucoseChart() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let minDate = dateInterval.start.timeIntervalSince1970
        let maxDate = dateInterval.end.timeIntervalSince1970
        
        let timeInterval = maxDate - minDate
        let pixelsPerSecond = Double(bounds.width - insets.left - insets.right) / timeInterval
        let yInterval = Double(bounds.height - insets.bottom - insets.top)
        let pixelsPerValue = yInterval / (yRange.upperBound - yRange.lowerBound)
        
        for (index, entry) in entries.enumerated() {
            let centerX = CGFloat((entry.date.timeIntervalSince1970 - minDate) * pixelsPerSecond) + insets.left
            let centerY = CGFloat((yRange.upperBound - entry.value) * pixelsPerValue) + insets.top
            if index == 0 {
                context.setLineWidth(1.0)
                context.setStrokeColor(UIColor.red.cgColor)
                context.move(to: CGPoint(x: centerX, y: centerY))
            } else {
                context.addLine(to: CGPoint(x: centerX, y: centerY))
                if index == entries.count - 1 {
                    context.strokePath()
                }
            }
        }
    }
}

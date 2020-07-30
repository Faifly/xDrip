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
    var entries: [BaseChartEntry] { get }
    var insets: UIEdgeInsets { get }
    var color: UIColor { get }
    
    func drawChart()
}

extension EntriesChartProvider where Self: UIView {
    func drawChart() {
        if entries.count < 2 { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let minDate = dateInterval.start.timeIntervalSince1970
        let maxDate = dateInterval.end.timeIntervalSince1970
        
        let timeInterval = maxDate - minDate
        let pixelsPerSecond = Double(bounds.width - insets.left - insets.right) / timeInterval
        let yInterval = Double(bounds.height - insets.bottom - insets.top)
        let pixelsPerValue = yInterval / (yRange.upperBound - yRange.lowerBound)
        var prevPoint: CGPoint?
        for (index, entry) in entries.enumerated() {
            let centerX = CGFloat((entry.date.timeIntervalSince1970 - minDate) * pixelsPerSecond) + insets.left
            let centerY = CGFloat((yRange.upperBound - entry.value) * pixelsPerValue) + insets.top
            let minY = CGFloat((yRange.upperBound - yRange.lowerBound) * pixelsPerValue) + insets.top
            let point = CGPoint(x: centerX, y: centerY)
            if index == 0 {
                context.beginPath()
                context.move(to: CGPoint(x: centerX, y: minY))
                context.addLine(to: point)
            } else {
                if let  prevPoint = prevPoint {
                    let midPoint = self.midPointForPoints(from: prevPoint, to: point)
                    context.addQuadCurve(to: point, control: controlPointForPoints(from: midPoint, to: point))
                }
                
                if index == entries.count - 1 {
                    context.addLine(to: CGPoint(x: centerX, y: minY))
                    context.closePath()
                    context.setFillColor(color.cgColor)
                    context.fillPath()
                }
            }
            prevPoint = point
        }
    }
    
    func midPointForPoints(from point1: CGPoint, to point2: CGPoint) -> CGPoint {
        return CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }
    
    func controlPointForPoints(from point1: CGPoint, to point2: CGPoint) -> CGPoint {
        var controlPoint = midPointForPoints(from: point1, to: point2)
        let  diffY = abs(point2.y - controlPoint.y)
        if point1.y < point2.y {
            controlPoint.y += diffY
        } else if point1.y > point2.y {
            controlPoint.y += diffY
        }
        return controlPoint
    }
}

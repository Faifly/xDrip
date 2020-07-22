//
//  BasalChartProvider.swift
//  xDrip
//
//  Created by Ivan Skoryk on 21.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol BasalChartProvider: GlucoseChartProvider {
    var yRangeBasal: ClosedRange<Double> { get }
    var basalEntries: [BasalChartBasalEntry] { get }
    var strokePoints: [BasalChartBasalEntry] { get }
    var basalDisplayMode: ChartSettings.BasalDisplayMode { get }
    var pixelPerValueBasal: Double { get set }
    var yIntervalBasal: Double { get set }
    
    func drawBasalStroke()
}

private struct BasalEntry: BasalChartBasalEntry {
    var value: Double
    var date: Date
}

extension BasalChartProvider where Self: GlucoseChartProvider & UIView {
    private var yMin: Double {
        return basalDisplayMode == .onBottom ? yInterval : 0
    }
    
    private var yMax: Double {
        return basalDisplayMode == .onBottom ? yInterval - yIntervalBasal : yIntervalBasal
    }
    
    func drawBasalStroke() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard basalDisplayMode != .notShown else { return }
        
        calculateValues()
        
        context.move(to: calcPoint(for: dateInterval.start, and: 0.0))
        if !strokePoints.isEmpty {
            context.move(to: calcPoint(for: strokePoints[0].date, and: strokePoints[0].value))
            
            for point in strokePoints.dropFirst() {
                context.addLine(to: calcPoint(for: point.date, and: point.value))
            }
        }
        context.addLine(to: calcPoint(for: strokePoints.last?.date ?? Date(), and: 0.0))
        context.addLine(to: CGPoint(x: bounds.width - insets.left - insets.right, y: CGFloat(yMin) + insets.top))
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.cyan.cgColor)
        let path = context.path
        context.drawPath(using: .stroke)
        completeBasalChart(for: path)
        markBasalEntries()
    }
    
    private func markBasalEntries() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for entry in basalEntries {
            let pointValue = strokePoints.filter({ $0.date == entry.date }).max(by: { $0.value < $1.value })?.value
            
            let point = calcPoint(for: entry.date, and: pointValue ?? 0.0)
            let circleRect = CGRect(
                x: point.x - circleSide / 2.0,
                y: point.y - circleSide / 2.0,
                width: circleSide,
                height: circleSide
            )
    
            context.setFillColor(UIColor.cyan.cgColor)
            context.fillEllipse(in: circleRect)
        }
    }
    
    private func completeBasalChart(for path: CGPath?) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let path = path else { return }
        context.addPath(path)
        
        let strokeInset: CGFloat = basalDisplayMode == .onBottom ? 2.0 : -2.0
        context.addLine(to: CGPoint(
                x: bounds.width - insets.left - insets.right,
                y: CGFloat(yMin) + insets.top + strokeInset
            )
        )
        context.addLine(to: CGPoint(x: 0.0, y: CGFloat(yMin) + insets.top + strokeInset))
        
        context.setFillColor(UIColor.cyan.withAlphaComponent(0.2).cgColor)
        context.drawPath(using: .fill)
    }
    
    private func calcPoint(for date: Date, and value: Double) -> CGPoint {
        guard basalDisplayMode != .notShown else { return .zero }
        
        let value = basalDisplayMode == .onBottom ? value : -value
        let yMax = basalDisplayMode == .onBottom ? self.yMax : -self.yMax
        
        let xPoint = CGFloat((date.timeIntervalSince1970 - minDate) * pixelsPerSecond) + insets.left
        let yPoint = CGFloat((yRangeBasal.upperBound - value) * pixelPerValueBasal) + insets.top + CGFloat(yMax)
        
        return CGPoint(x: xPoint, y: yPoint)
    }
    
    private func calculateValues() {
        minDate = dateInterval.start.timeIntervalSince1970
        maxDate = dateInterval.end.timeIntervalSince1970
        timeInterval = maxDate - minDate
        pixelsPerSecond = Double(bounds.width - insets.left - insets.right) / timeInterval
        yInterval = Double(bounds.height - insets.bottom - insets.top)
        pixelsPerValue = yInterval / (yRange.upperBound - yRange.lowerBound)
        yIntervalBasal = yInterval / 4.0
        pixelPerValueBasal = yIntervalBasal / (yRangeBasal.upperBound - yRangeBasal.lowerBound)
    }
}

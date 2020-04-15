//
//  GlucoseChartView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol GlucoseChartProvider {
    var dateInterval: DateInterval { get }
    var yRange: ClosedRange<Double> { get }
    var entries: [GlucoseChartGlucoseEntry] { get }
    var insets: UIEdgeInsets { get }
    var circleSide: CGFloat { get }
    
    func drawGlucoseChart()
}

extension GlucoseChartProvider where Self: UIView {
    func drawGlucoseChart() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let minDate = dateInterval.start.timeIntervalSince1970
        let maxDate = dateInterval.end.timeIntervalSince1970
        
        let timeInterval = maxDate - minDate
        let pixelsPerSecond = Double(bounds.width - insets.left - insets.right) / timeInterval
        let yInterval = Double(bounds.height - insets.bottom - insets.top)
        let pixelsPerValue = yInterval / (yRange.upperBound - yRange.lowerBound)
        
        context.setLineWidth(0.0)
        
        for entry in entries {
            print(entry)
            let centerX = CGFloat((entry.date.timeIntervalSince1970 - minDate) * pixelsPerSecond) + insets.left
            let centerY = CGFloat((yRange.upperBound - entry.value) * pixelsPerValue) + insets.top
            let circleRect = CGRect(
                x: centerX - circleSide / 2.0,
                y: centerY - circleSide / 2.0,
                width: circleSide,
                height: circleSide
            )
            
            let color: UIColor
            switch entry.severity {
            case .low: color = .yellow
            case .normal: color = .green
            case .high: color = .red
            }
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: circleRect)
        }
    }
}

final class GlucoseChartView: BaseChartView, GlucoseChartProvider {
    var entries: [GlucoseChartGlucoseEntry] = []
    let circleSide: CGFloat = 6.0
    var dateInterval = DateInterval()
    var yRange: ClosedRange<Double> = 0.0...0.0
    var insets: UIEdgeInsets {
        return chartInsets
    }
    
    required init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawGlucoseChart()
    }
}

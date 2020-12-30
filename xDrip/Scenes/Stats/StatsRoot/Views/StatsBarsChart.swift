//
//  StatsBarsChart.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name

final class StatsBarsChart: BaseChartView {
    var entries: [StatsChartEntry] = [] {
        didSet {
            relativeHorizontalInterval = 1.0 / CGFloat(entries.count)
            calculateMinMax()
            horizontalLabels = entries.map { $0.descriptor }
            selectedSector = nil
        }
    }
    
    var onSelectionChange: ((Int?) -> Void)?
    
    private var minValue: Double = 0.0
    private var maxValue: Double = 0.0
    private(set) var visualMinValue: Double = 0.0
    private(set) var visualMaxValue: Double = 0.0
    let verticalCount = 8
    
    private var selectedSector: Int? {
        didSet {
            onSelectionChange?(selectedSector)
        }
    }
    
    required init() {
        super.init(frame: .zero)
        isOpaque = false
        horizontalLabelsFont = .systemFont(ofSize: 11.0, weight: .regular)
        verticalLinesCount = verticalCount
        translatesAutoresizingMaskIntoConstraints = false
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
        recognizer.minimumPressDuration = 0.2
        addGestureRecognizer(recognizer)
        
        chartInsets.top = 0.0
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    private let lineWidth: CGFloat = 8.0
    private let lineColorNormal = UIColor(
        red: 255.0 / 255.0,
        green: 45.0 / 255.0,
        blue: 85.0 / 255.0,
        alpha: 0.32
    ).cgColor
    private let lineColorSelected = UIColor(
        red: 255.0 / 255.0,
        green: 45.0 / 255.0,
        blue: 85.0 / 255.0,
        alpha: 1.0
    ).cgColor
    private let selectionIndicatorColor = UIColor.statsChartSelection.cgColor
    
    private let circleLineWidth: CGFloat = 1.0
    private let circleFillColor = UIColor.white.cgColor
    
    private let curveWidth: CGFloat = 1.0
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawBars(context)
        drawCurve(context)
    }
    
    private func drawBars(_ context: CGContext) {
        let widthPerSector = bounds.width / CGFloat(entries.count)
        var currentOffset: CGFloat = 0.0
        
        for (index, entry) in entries.enumerated() {
            guard entry.hasValue, let value = entry.value else {
                currentOffset += widthPerSector
                continue
            }
            
            let yInterval = Double(bounds.height - chartInsets.bottom - chartInsets.top)
            let pixelsPerValue = yInterval / (visualMaxValue - visualMinValue)
            
            let lineCenter = widthPerSector / 2.0 + currentOffset
            let lineTop = CGFloat((visualMaxValue - value.upperBound) * pixelsPerValue)
            let lineBottom = CGFloat((visualMaxValue - value.lowerBound) * pixelsPerValue)
            
            context.setLineWidth(lineWidth)
            
            if index == selectedSector {
                context.setStrokeColor(lineColorSelected)
            } else {
                context.setStrokeColor(lineColorNormal)
            }
            
            context.addLines(between: [
                CGPoint(x: lineCenter, y: lineTop),
                CGPoint(x: lineCenter, y: lineBottom)
            ])
            context.strokePath()
            
            drawCircles(
                lineTop: lineTop,
                lineBottom: lineBottom,
                lineCenter: lineCenter,
                context: context,
                index: index
            )
            
            if selectedSector == index {
                drawSelectionIndicator(context: context, lineTop: lineTop, lineCenter: lineCenter)
            }
            
            currentOffset += widthPerSector
        }
    }
    
    private func drawCircles(lineTop: CGFloat,
                             lineBottom: CGFloat,
                             lineCenter: CGFloat,
                             context: CGContext,
                             index: Int) {
        context.setLineWidth(circleLineWidth)
        if index == selectedSector {
            context.setStrokeColor(lineColorNormal)
        } else {
            context.setStrokeColor(lineColorSelected)
        }
        context.setFillColor(circleFillColor)
        
        let highCircleRect = CGRect(
            x: lineCenter - lineWidth / 2.0,
            y: lineTop - lineWidth / 2.0,
            width: lineWidth,
            height: lineWidth
        )
        let lowCircleRect = CGRect(
            x: lineCenter - lineWidth / 2.0,
            y: lineBottom - lineWidth / 2.0,
            width: lineWidth,
            height: lineWidth
        )
        context.addEllipse(in: highCircleRect)
        context.addEllipse(in: lowCircleRect)
        
        if index == selectedSector {
            let middleCircleRect = CGRect(
                x: lineCenter - lineWidth / 2.0,
                y: (lineBottom + lineTop) / 2.0 - lineWidth / 2.0,
                width: lineWidth,
                height: lineWidth
            )
            context.addEllipse(in: middleCircleRect)
        }
        
        context.drawPath(using: .fillStroke)
    }
    
    private func drawSelectionIndicator(context: CGContext, lineTop: CGFloat, lineCenter: CGFloat) {
        context.setStrokeColor(selectionIndicatorColor)
        context.setLineWidth(2.0)
        context.addLines(between: [
            CGPoint(x: lineCenter, y: lineTop - lineWidth / 2.0 - 3.0),
            CGPoint(x: lineCenter, y: 0.0)
        ])
        context.strokePath()
    }
    
    private func drawCurve(_ context: CGContext) {
        let widthPerSector = bounds.width / CGFloat(entries.count)
        
        context.setLineWidth(curveWidth)
        context.setStrokeColor(lineColorSelected)
        
        var index1 = 0
        var index2 = 1
        
        while index2 < entries.count {
            let entry1 = entries[index1]
            guard entry1.hasValue, let value1 = entry1.value else {
                index1 += 1
                index2 += 1
                continue
            }
            
            let entry2 = entries[index2]
            guard entry2.hasValue, let value2 = entry2.value else {
                index2 += 1
                continue
            }
            
            let x1 = widthPerSector * CGFloat(index1 + 1) - widthPerSector / 2.0
            let x2 = widthPerSector * CGFloat(index2 + 1) - widthPerSector / 2.0
            
            let yInterval = Double(bounds.height - chartInsets.bottom - chartInsets.top)
            let pixelsPerValue = yInterval / (visualMaxValue - visualMinValue)
            
            let entry1Top = CGFloat((visualMaxValue - value1.upperBound) * pixelsPerValue)
            let entry1Bottom = CGFloat((visualMaxValue - value1.lowerBound) * pixelsPerValue)
            
            let entry2Top = CGFloat((visualMaxValue - value2.upperBound) * pixelsPerValue)
            let entry2Bottom = CGFloat((visualMaxValue - value2.lowerBound) * pixelsPerValue)
            
            let y1 = (entry1Top + entry1Bottom) / 2.0
            let y2 = (entry2Top + entry2Bottom) / 2.0
            
            let controlPoint1 = CGPoint(x: (x2 + x1) / 2.0, y: y1)
            let controlPoint2 = CGPoint(x: (x2 + x1) / 2.0, y: y2)
            
            context.move(to: CGPoint(x: x1, y: y1))
            context.addCurve(to: CGPoint(x: x2, y: y2), control1: controlPoint1, control2: controlPoint2)
            context.strokePath()
            
            index1 = index2
            index2 += 1
        }
    }
    
    private func calculateMinMax() {
        let visualCorrelationFactor = 0.01
        
        let values = entries.compactMap { $0.value }
        
        minValue = values.min(by: { $0.lowerBound < $1.lowerBound })?.lowerBound ?? 0.0
        maxValue = values.max(by: { $0.upperBound < $1.upperBound })?.upperBound ?? 0.0
        
        var minVal = minValue * 10.0
        var maxVal = maxValue * 10.0
   
        let alphaValue = 0.20 * (maxVal - minVal)
        var axisRightMax = Int(round(maxVal + alphaValue))
        var axisRightMin = Int(minVal - alphaValue)

        if axisRightMin < 0 { axisRightMin = 0 }

        let range = Int(axisRightMax - axisRightMin)
        let tail = range % (verticalCount - 1)
        if tail != 0 {
            axisRightMax += (verticalCount - 1) - tail
        }
        
        minVal = Double(axisRightMin) / 10.0
        maxVal = Double(axisRightMax) / 10.0
        
        visualMinValue = max((minVal * (1.0 - visualCorrelationFactor)).rounded(.down), 0.0)
        visualMaxValue = (maxVal * (1.0 + visualCorrelationFactor)).rounded(.up)
    }
    
    @objc private func handleTouch(_ sender: UIGestureRecognizer) {
        let location = sender.location(in: self)
        let selectedSector = Int(location.x / (bounds.width / CGFloat(entries.count)))
        if self.selectedSector != selectedSector {
            self.selectedSector = selectedSector
            setNeedsDisplay()
        }
    }
}

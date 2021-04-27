//
//  BaseChartView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 10.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

struct ChartBottomLabel {
    let title: String
    let isCentered: Bool
    
    init(title: String, isCentered: Bool = false) {
        self.title = title
        self.isCentered = isCentered
    }
}

struct ChartFormattedBottomLabel {
    let title: NSAttributedString
    let isCentered: Bool
    
    init(title: NSAttributedString, isCentered: Bool = false) {
        self.title = title
        self.isCentered = isCentered
    }
}

class BaseChartView: UIView {
    var yRange: ClosedRange<Double> = 0.0...0.0
    var dateInterval = DateInterval()
    var chartInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: 26.0, right: 0.0)
    
    var relativeHorizontalStartingOffset: CGFloat = 0.0
    private var absoluteHorizontalStartingOffset: CGFloat {
        return bounds.width * relativeHorizontalStartingOffset
    }
    
    var relativeHorizontalInterval: CGFloat = 1.0
    private var absoluteHorizontalInterval: CGFloat {
        return bounds.width * relativeHorizontalInterval
    }
    
    var verticalLinesCount: Int = 0
    
    /// Strings to be displayed on horizontal axis
    var horizontalLabels: [ChartBottomLabel] = [] {
        didSet {
            formatHorizontalLabels()
        }
    }
    
    var horizontalLabelsFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    private var formattedHorizontalLabels: [ChartFormattedBottomLabel] = []
    
    private func formatHorizontalLabels() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let attributes: [NSAttributedString.Key: Any] = [
            .font: horizontalLabelsFont,
            .foregroundColor: UIColor.chartTextColor,
            .paragraphStyle: paragraphStyle
        ]
   
        formattedHorizontalLabels = horizontalLabels.map {
            ChartFormattedBottomLabel(title: NSAttributedString(string: $0.title, attributes: attributes),
                                      isCentered: $0.isCentered)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawVerticalGrid(context: context)
        drawHorizontalGrid(context: context)
    }
    
    private func drawVerticalGrid(context: CGContext) {
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.chartGridLineColor.cgColor)
        
        var offset = chartInsets.top
        let lineDistance = (bounds.height - chartInsets.top - chartInsets.bottom) / CGFloat(verticalLinesCount - 1)
        
        for _ in 0..<verticalLinesCount {
            let start = CGPoint(x: chartInsets.left, y: offset)
            let end = CGPoint(x: bounds.width - chartInsets.right, y: offset)
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
            
            offset += lineDistance
        }
    }
    
    private func drawHorizontalGrid(context: CGContext) {
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.chartGridLineColor.cgColor)
        context.setLineDash(phase: 1.0, lengths: [4.0, 2.0])
        
        var offset = chartInsets.left + absoluteHorizontalStartingOffset
        let linesLimit = bounds.width - chartInsets.right
        var index = 0
        while offset < linesLimit {
            let start = CGPoint(x: offset, y: chartInsets.top)
            let end = CGPoint(x: offset, y: bounds.height - chartInsets.bottom)
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
            
            if index < formattedHorizontalLabels.count {
                let isCentered = formattedHorizontalLabels[index].isCentered
                let labelRect = isCentered
                    ? CGRect(x: offset - 14.0,
                             y: end.y + 6.0,
                             width: absoluteHorizontalInterval + 6.0,
                             height: 16.0)
                    : CGRect(x: offset, y: end.y + 6.0, width: absoluteHorizontalInterval, height: 16.0)
                formattedHorizontalLabels[index].title.draw(in: labelRect)
                index += 1
            }
            
            offset += absoluteHorizontalInterval
        }
        
        context.setLineDash(phase: 0.0, lengths: [])
    }
}

//
//  ChartVerticalLabelsView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 14.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class ChartVerticalLabelsView: UIView {
    var chartInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: 26.0, right: 0.0)
    
    var textAlignment: NSTextAlignment = .right {
        didSet {
            formatLabels()
        }
    }
    
    var labels: [String] = [] {
        didSet {
            formatLabels()
        }
    }
    
    var font: UIFont = .systemFont(ofSize: 14.0, weight: .regular)
    
    private var formattedLabels: [NSAttributedString] = []
    
    private func formatLabels() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.chartTextColor,
            .paragraphStyle: paragraphStyle
        ]
        formattedLabels = labels.map { NSAttributedString(string: $0, attributes: attributes) }
    }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isOpaque = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.chartGridLineColor.cgColor)
        
        var offset = chartInsets.top
        let lineDistance = (bounds.height - chartInsets.top - chartInsets.bottom) / CGFloat(formattedLabels.count - 1)
        
        for label in formattedLabels.reversed() {
            label.draw(in: CGRect(x: 0.0, y: offset - 9.0, width: 32.0, height: 16.0))
            offset += lineDistance
        }
    }
}

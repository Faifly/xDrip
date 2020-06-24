//
//  EntriesChartView.swift
//  xDrip
//
//  Created by Dmitry on 6/23/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

import UIKit

final class EntriesChartView: BaseChartView, EntriesChartProvider {
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
        backgroundColor = .background1
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawGlucoseChart()
    }
}

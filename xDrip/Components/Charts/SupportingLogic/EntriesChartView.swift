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
    var entries: [BaseChartEntry] = []
    var insets: UIEdgeInsets {
        return chartInsets
    }
    var color = UIColor.clear
    
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
        drawChart()
    }
}

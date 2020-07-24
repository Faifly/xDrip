//
//  GlucoseHistoryView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class GlucoseHistoryView: BaseHistoryView {
    let chartSliderView = ChartSliderView()
    var glucoseChartView = GlucoseChartView()
    var glucoseEntries: [GlucoseChartGlucoseEntry] = []

    override var chartView: BaseChartView {
        get {
            return glucoseChartView
        }
        set {
            glucoseChartView = newValue as? GlucoseChartView ?? GlucoseChartView()
        }
    }
    
    override var entries: [BaseChartEntry] {
        get {
            return glucoseEntries
        }
        set {
            glucoseEntries = newValue as? [GlucoseChartGlucoseEntry] ?? []
        }
    }
    
    func setup(
        entries: [BaseChartEntry],
        basalDisplayMode: ChartSettings.BasalDisplayMode,
        basalEntries: [BasalChartBasalEntry],
        strokeChartEntries: [BasalChartBasalEntry],
        unit: String
    ) {
        
    }
    
    override func setupViews() {
        super.setupViews()
        addSubview(chartSliderView)
        chartSliderView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        chartSliderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartSliderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        chartSliderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftLabelsView.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        scrollContainer.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        setupSeparator(bottomView: self)
        setupSeparator(bottomView: chartView)
    }
    
    override func setupOnRelativeOffsetChanged() {
        chartSliderView.onRelativeOffsetChanged = { [weak self] offset in
            guard let self = self else { return }
            let contentWidth = self.scrollContainer.scrollView.contentSize.width
            let maxPossibleOffset = (contentWidth - self.scrollContainer.bounds.width) / contentWidth
            self.scrollContainer.scrollView.contentOffset = CGPoint(
                x: contentWidth * offset + 30.0 * offset / maxPossibleOffset,
                y: 0.0
            )
            self.updateDetailLabel()
        }
    }
    
    override func updateChartSliderView(with scrollSegments: CGFloat) {
        chartSliderView.currentRelativeOffset = (scrollSegments - 1.0) / scrollSegments
        chartSliderView.sliderRelativeWidth = 1.0 / scrollSegments
        chartSliderView.glucoseEntries = glucoseEntries
        chartSliderView.dateInterval = globalDateRange
        chartSliderView.yRange = chartView.yRange
        chartSliderView.setNeedsDisplay()
    }
}

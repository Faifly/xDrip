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
    private let rightLabelsView = ChartVerticalLabelsView()
    private var basalDisplayMode: ChartSettings.BasalDisplayMode = .notShown
    private var basalEntries: [BasalChartBasalEntry] = []
    private var strokeChartEntries: [BasalChartBasalEntry] = []
    private var rightLegendAnchorConstraint: NSLayoutConstraint?

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
        with entries: [GlucoseChartGlucoseEntry],
        basalDisplayMode: ChartSettings.BasalDisplayMode,
        basalEntries: [BasalChartBasalEntry],
        strokeChartEntries: [BasalChartBasalEntry],
        unit: String
    ) {
        self.basalDisplayMode = basalDisplayMode
        self.basalEntries = basalEntries
        self.strokeChartEntries = strokeChartEntries
        self.glucoseChartView.glucoseEntries = entries
        super.setup(with: entries, unit: unit)
    }
    
    override func setupViews() {
        super.setupViews()
        addSubview(chartSliderView)
        addSubview(rightLabelsView)
        chartSliderView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        chartSliderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartSliderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        chartSliderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftLabelsView.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        scrollContainer.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        setupSeparator(bottomView: self)
        setupSeparator(bottomView: chartView)
        setupRightLabelViewsAnchorConstraint()
        rightLabelsView.heightAnchor.constraint(
            equalTo: scrollContainer.heightAnchor,
            multiplier: 1.0 / 4.0,
            constant: rightLabelsView.chartInsets.bottom
        ).isActive = true
        rightLabelsView.leadingAnchor.constraint(equalTo: scrollContainer.trailingAnchor, constant: 8.0).isActive = true
        rightLabelsView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        rightLabelsView.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
    }
    
    private func setupRightLabelViewsAnchorConstraint() {
        rightLegendAnchorConstraint?.isActive = false
        if basalDisplayMode == .onTop {
            rightLegendAnchorConstraint = rightLabelsView.topAnchor.constraint(equalTo: scrollContainer.topAnchor)
        } else {
            rightLegendAnchorConstraint = rightLabelsView.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor)
        }
        rightLegendAnchorConstraint?.isActive = true
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
    
    private func calculateVerticalRightLabels() {
        var labels = [String]()
        let format = "home_basal_units".localized
        
        let initVal = BasalChartDataWorker.getBasalValueForDate(date: chartView.dateInterval.start)
        let maxBasalValue = basalEntries.max(by: { $0.value < $1.value })?.value
        let adjustedMaxValue = max(initVal, maxBasalValue ?? 0.0).rounded(.up)
        labels.append(String(format: format, 0.0))
        labels.append(String(format: format, adjustedMaxValue))
        
        rightLabelsView.textAlignment = .left
        rightLabelsView.labels = basalDisplayMode == .onBottom ? labels : labels.reversed()
        rightLabelsView.setNeedsDisplay()
        
        if adjustedMaxValue ~~ 0.0 {
            glucoseChartView.yRangeBasal = 0.0...(adjustedMaxValue + 1.0)
        } else {
            glucoseChartView.yRangeBasal = 0.0...adjustedMaxValue
        }
    }
}

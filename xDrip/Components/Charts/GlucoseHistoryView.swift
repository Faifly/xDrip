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
    let detailsView = ChartEntryDetailView()
    var glucoseEntries: [GlucoseChartGlucoseEntry] = []
    private let rightLabelsView = ChartVerticalLabelsView()
    private var basalDisplayMode: ChartSettings.BasalDisplayMode = .notShown
    private var basalEntries: [BasalChartBasalEntry] = []
    private var strokeChartEntries: [BasalChartBasalEntry] = []
    private var rightLegendAnchorConstraint: NSLayoutConstraint?
    var unit = ""

    override var chartView: BaseChartView {
        get {
            return glucoseChartView
        }
        set {
            glucoseChartView = newValue as? GlucoseChartView ?? GlucoseChartView()
        }
    }
        
    func setup(
        with entries: [GlucoseChartGlucoseEntry],
        basalDisplayMode: ChartSettings.BasalDisplayMode,
        basalEntries: [BasalChartBasalEntry],
        strokeChartEntries: [BasalChartBasalEntry],
        unit: String
    ) {
//        let entries = MockedEntries.glucoseEntries
        self.glucoseEntries = entries
        self.glucoseChartView.glucoseEntries = entries
        self.basalDisplayMode = basalDisplayMode
        self.basalEntries = basalEntries
        self.strokeChartEntries = strokeChartEntries
        self.unit = unit
        super.update()
    }
    
    override func setupViews() {
        super.setupViews()
        addSubview(chartSliderView)
        addSubview(rightLabelsView)
        addSubview(detailsView)
        detailsView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
        detailsView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor).isActive = true
        detailsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        detailsView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        chartSliderView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        chartSliderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartSliderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        chartSliderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftLabelsView.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        scrollContainer.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        scrollContainer.topAnchor.constraint(equalTo: detailsView.bottomAnchor).isActive = true
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
    
    override func updateDetailView(with relativeOffset: CGFloat) {
        updateDetailLabel()
        detailsView.setRelativeOffset(relativeOffset)
      }
    
    override func setTimeFrame(_ localInterval: TimeInterval) {
        super.setTimeFrame(localInterval)
         detailsView.setHidden(true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        detailsView.setHidden(true)
    }
    
    override func updateChart() {
        calculateVerticalLeftLabels(minValue: glucoseEntries.map({ $0.value }).min(),
                                    maxValue: glucoseEntries.map({ $0.value }).max())
        super.updateChart()
        setupRightLabelViewsAnchorConstraint()
        calculateVerticalRightLabels()
    }
    
    func updateDetailLabel() {
        guard let userRelativeSelection = userRelativeSelection else { return }
        let scrollView = scrollContainer.scrollView
        let currentRelativeOffset = scrollView.contentOffset.x / scrollView.contentSize.width
        let scrollSegments = TimeInterval(
            (globalDateRange.duration - forwardTimeOffset) / (localDateRange.duration - forwardTimeOffset)
        )
        let globalDurationOffset = globalDateRange.duration * TimeInterval(currentRelativeOffset)
        let localOffsettedInterval = localInterval + forwardTimeOffset / scrollSegments
        let localDurationOffset = localOffsettedInterval * TimeInterval(userRelativeSelection)
        let currentRelativeStartTime = globalDurationOffset + localDurationOffset
        let selectedDate = globalDateRange.start + currentRelativeStartTime
        if let entry = nearestEntry(forDate: selectedDate) {
            detailsView.set(value: entry.value, unit: unit, date: entry.date)
            detailsView.setHidden(false)
        } else {
            detailsView.setHidden(true)
        }
    }
    
    private func nearestEntry(forDate date: Date) -> GlucoseChartGlucoseEntry? {
        let maxDiff: TimeInterval = .secondsPerMinute * 5.0
        
        if glucoseEntries.isEmpty {
            return nil
        } else if glucoseEntries.count == 1 {
            let diff = abs(date.timeIntervalSince1970 - glucoseEntries[0].date.timeIntervalSince1970)
            return diff <= maxDiff ? glucoseEntries[0] : nil
        }
        
        let diffs = glucoseEntries.map { abs(date.timeIntervalSince1970 - $0.date.timeIntervalSince1970) }
        var minDiff = Double.greatestFiniteMagnitude
        var minDiffIndex = 0
        for (index, diff) in diffs.enumerated() where diff < minDiff {
            minDiff = diff
            minDiffIndex = index
        }
        
        return minDiff <= maxDiff ? glucoseEntries[minDiffIndex] : nil
    }
}

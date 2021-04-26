//
//  GlucoseHistoryView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class GlucoseHistoryView: BaseHistoryView {
    private let chartSliderView = ChartSliderView()
    private var glucoseChartView = GlucoseChartView()
    private var detailsView: ChartEntryDetailView?
    private var glucoseEntries: [GlucoseChartGlucoseEntry] = []
    private let rightLabelsView = ChartVerticalLabelsView()
    private var basalDisplayMode: ChartSettings.BasalDisplayMode = .notShown
    private var basalEntries: [BasalChartBasalEntry] = []
    private var strokeChartEntries: [BasalChartBasalEntry] = []
    private var rightLegendAnchorConstraint: NSLayoutConstraint?
    private var unit = ""
    
    private var scrollContainerTopConstraint: NSLayoutConstraint?
    
    var updateGlucoseDataViewCallback: ((DateInterval) -> Void)?
    
    var detailsEnabled: Bool = true {
        didSet {
            setupDetailsView()
        }
    }

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
        self.glucoseEntries = entries
        self.glucoseChartView.glucoseEntries = entries
        self.basalDisplayMode = basalDisplayMode
        self.basalEntries = basalEntries
        self.strokeChartEntries = strokeChartEntries
        self.unit = unit
        super.update()
    }
    
    override func setupViews() {
        backgroundColor = .background1
        super.setupViews()
        addSubview(chartSliderView)
        addSubview(rightLabelsView)
        setupDetailsView()
        chartSliderView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        chartSliderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartSliderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        chartSliderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftLabelsView.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        scrollContainer.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        setupSeparator(bottomView: self)
        setupSeparator(bottomView: glucoseChartView)
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
    
    func setupDetailsView() {
        if let detailsView = detailsView {
            NSLayoutConstraint.deactivate(detailsView.constraints)
            detailsView.removeFromSuperview()
        }
        scrollContainerTopConstraint?.isActive = false
        scrollContainerTopConstraint = scrollContainer.topAnchor.constraint(equalTo: topAnchor, constant: 8.0)
        scrollContainerTopConstraint?.isActive = true
        
        if detailsEnabled {
            let detailsView = ChartEntryDetailView()
            addSubview(detailsView)
            detailsView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
            detailsView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor).isActive = true
            detailsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            detailsView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
            scrollContainerTopConstraint?.isActive = false
            scrollContainerTopConstraint = scrollContainer.topAnchor.constraint(equalTo: detailsView.bottomAnchor)
            scrollContainerTopConstraint?.isActive = true
            
            self.detailsView = detailsView
        }
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
            self.updateGlucoseDataView()
        }
    }
    
    override func updateChartSliderView(with scrollSegments: CGFloat) {
        chartSliderView.currentRelativeOffset = (scrollSegments - 1.0) / scrollSegments
        chartSliderView.sliderRelativeWidth = 1.0 / scrollSegments
        chartSliderView.glucoseEntries = glucoseEntries
        chartSliderView.dateInterval = globalDateRange
        chartSliderView.yRange = glucoseChartView.yRange
        chartSliderView.setNeedsDisplay()
    }
    
    private func calculateVerticalRightLabels() {
        var labels = [String]()
        let format = "home_basal_units".localized
        
        let initVal = BasalChartDataWorker.getBasalValueForDate(date: glucoseChartView.dateInterval.start)
        let maxBasalValue = basalEntries.max(by: { $0.value < $1.value })?.value
        let adjustedMaxValue = max(initVal, maxBasalValue ?? 0.0).rounded(.up)
        
        if basalDisplayMode != .notShown {
            labels.append(String(format: format, 0.0))
            if adjustedMaxValue > 0.0 {
                labels.append(String(format: format, adjustedMaxValue))
            }
        }
        
        if basalDisplayMode == .onBottom && labels.count == 1 {
            labels.append("")
        }
        
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
        detailsView?.setRelativeOffset(relativeOffset)
      }
    
    override func setLocalTimeFrame(_ localInterval: TimeInterval) {
        super.setLocalTimeFrame(localInterval)
        detailsView?.setHidden(true)
    }
    
    override func setGlobalTimeFrame(_ globalInterval: TimeInterval) {
        super.setGlobalTimeFrame(globalInterval)
        detailsView?.setHidden(true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        detailsView?.setHidden(true)
    }
    
    override func updateChart() {
        super.calculateVerticalLeftLabels(minValue: glucoseEntries.map({ $0.value }).min(),
                                          maxValue: glucoseEntries.map({ $0.value }).max())
        super.updateChart()
        updateGlucoseDataView()
        setupRightLabelViewsAnchorConstraint()
        calculateVerticalRightLabels()
        glucoseChartView.basalEntries = basalEntries
        glucoseChartView.strokePoints = strokeChartEntries
        glucoseChartView.dateInterval = globalDateRange
        glucoseChartView.basalDisplayMode = basalDisplayMode
        glucoseChartView.setNeedsDisplay()
        
        let scrollSegments = max(
            CGFloat(
                (globalDateRange.duration - forwardTimeOffset) / (localDateRange.duration - forwardTimeOffset)
            ),
            1.0
        )
        
        var chartWidth = scrollContainer.bounds.width * scrollSegments
        #if os(iOS)
        let width = UIScreen.main.bounds.width
        if width < 414.0 {
            multiplier = 1.6 + (414.0 / width) - 1
        }
        #endif
        chartWidth *= multiplier
        chartWidthConstraint?.constant = chartWidth
        updateChartSliderView(with: scrollSegments * multiplier)
        scrollContainer.layoutIfNeeded()
        scrollContainer.scrollView.contentOffset = CGPoint(x: chartWidth - scrollContainer.bounds.width, y: 0.0)
    }
    
    private func updateGlucoseDataView() {
        guard let callback = updateGlucoseDataViewCallback else { return }
        let scrollView = scrollContainer.scrollView
        let currentRelativeOffset = scrollView.contentOffset.x / scrollView.contentSize.width
        let globalDurationOffset = globalDateRange.duration * TimeInterval(currentRelativeOffset)
        let localOffsettedInterval = localInterval / Double(multiplier)
        let endDate = globalDateRange.start + globalDurationOffset + localOffsettedInterval
        let dateInterval = DateInterval(endDate: endDate, duration: localOffsettedInterval)
        callback(dateInterval)
    }
    
    func updateDetailLabel() {
        guard detailsEnabled else { return }
        guard let userRelativeSelection = userRelativeSelection else { return }
        let scrollView = scrollContainer.scrollView
        let currentRelativeOffset = scrollView.contentOffset.x / scrollView.contentSize.width
        let scrollSegments = TimeInterval(
            (globalDateRange.duration - forwardTimeOffset) / (localDateRange.duration - forwardTimeOffset)
        )
        let globalDurationOffset = globalDateRange.duration * TimeInterval(currentRelativeOffset)
        let localOffsettedInterval = localInterval + forwardTimeOffset / scrollSegments
        let localDurationOffset = localOffsettedInterval * TimeInterval(userRelativeSelection) / Double(multiplier)
        let currentRelativeStartTime = globalDurationOffset + localDurationOffset
        let selectedDate = globalDateRange.start + currentRelativeStartTime
        if let entry = nearestEntry(forDate: selectedDate) {
            detailsView?.set(value: entry.value, unit: unit, date: entry.date)
            detailsView?.setHidden(false)
        } else {
            detailsView?.setHidden(true)
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

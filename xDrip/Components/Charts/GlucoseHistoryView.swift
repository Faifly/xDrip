//
//  GlucoseHistoryView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class GlucoseHistoryView: UIView {
    private let verticalLines: Int = 5
    private var forwardTimeOffset: TimeInterval = 600.0
    
    private let scrollContainer = GlucoseChartScrollContainer()
    private let detailsView = ChartEntryDetailView()
    private let leftLabelsView = ChartVerticalLabelsView()
    private let chartView = GlucoseChartView()
    private let chartSliderView = ChartSliderView()
    private weak var chartWidthConstraint: NSLayoutConstraint?
    
    private var glucoseEntries: [GlucoseChartGlucoseEntry] = []
    private var basalEntries: [BasalChartEntry] = []
    
    private var globalDateRange = DateInterval()
    private var localDateRange = DateInterval()
    private var localInterval: TimeInterval = .secondsPerHour
    private var userRelativeSelection: CGFloat?
    private var unit = GlucoseUnit.default.label
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
        setupScrolling()
        setTimeFrame(.secondsPerHour)
    }
    
    private func setupViews() {
        isOpaque = false
        backgroundColor = .background1
        
        addSubview(detailsView)
        addSubview(leftLabelsView)
        addSubview(scrollContainer)
        scrollContainer.scrollView.addSubview(chartView)
        addSubview(chartSliderView)
        
        detailsView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
        detailsView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor).isActive = true
        detailsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        detailsView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        chartSliderView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        chartSliderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartSliderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        chartSliderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        leftLabelsView.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        leftLabelsView.topAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
        leftLabelsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftLabelsView.trailingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
        leftLabelsView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        scrollContainer.bottomAnchor.constraint(equalTo: chartSliderView.topAnchor).isActive = true
        scrollContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        scrollContainer.topAnchor.constraint(equalTo: detailsView.bottomAnchor).isActive = true
        
        chartView.bindToSuperview()
        chartView.heightAnchor.constraint(equalTo: scrollContainer.heightAnchor, multiplier: 1.0).isActive = true
        let chartViewWidth = chartView.widthAnchor.constraint(equalToConstant: bounds.width)
        chartViewWidth.isActive = true
        chartWidthConstraint = chartViewWidth
        
        setupSeparator(bottomView: self)
        setupSeparator(bottomView: chartView)
    }
    
    private func setupSeparator(bottomView: UIView) {
        let separator = UIView()
        separator.backgroundColor = .borderColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        separator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
    }
    
    private func setupScrolling() {
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
        
        scrollContainer.onSelectionChanged = { [weak self] relativeOffset in
            guard let self = self else { return }
            self.userRelativeSelection = relativeOffset
            self.updateDetailLabel()
            self.detailsView.setRelativeOffset(relativeOffset)
        }
    }
    
    func setTimeFrame(_ localInterval: TimeInterval) {
        self.localInterval = localInterval
        forwardTimeOffset = horizontalInterval(for: localInterval)
        scrollContainer.hideDetailView()
        detailsView.setHidden(true)
        updateIntervals()
        updateChart()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
        scrollContainer.hideDetailView()
        detailsView.setHidden(true)
    }
    
    /// Should be sorted by date ascending
    func setup(with entries: [GlucoseChartGlucoseEntry], basal: [BasalChartEntry], unit: String) {
        self.unit = unit
        glucoseEntries = entries
        basalEntries = basal
        updateIntervals()
        updateChart()
    }
    
    private func updateIntervals() {
        globalDateRange = DateInterval(
            endDate: Date() + forwardTimeOffset,
            duration: .secondsPerDay + forwardTimeOffset
        )
        localDateRange = DateInterval(endDate: globalDateRange.end, duration: localInterval + forwardTimeOffset)
    }
    
    private func updateChart() {
        calculateVerticalLeftLabels()
        calculateHorizontalBottomLabels()
        
        let scrollSegments = CGFloat(
            (globalDateRange.duration - forwardTimeOffset) / (localDateRange.duration - forwardTimeOffset)
        )
        let chartWidth = scrollContainer.bounds.width * scrollSegments
        chartWidthConstraint?.constant = chartWidth
        
        chartView.entries = glucoseEntries
        chartView.basalEntries = basalEntries
        chartView.dateInterval = globalDateRange
        chartView.setNeedsDisplay()
        
        chartSliderView.currentRelativeOffset = (scrollSegments - 1.0) / scrollSegments
        chartSliderView.sliderRelativeWidth = 1.0 / scrollSegments
        chartSliderView.entries = glucoseEntries
        chartSliderView.dateInterval = globalDateRange
        chartSliderView.yRange = chartView.yRange
        chartSliderView.setNeedsDisplay()
        
        scrollContainer.layoutIfNeeded()
        scrollContainer.scrollView.contentOffset = CGPoint(x: chartWidth - scrollContainer.bounds.width, y: 0.0)
    }
    
    private func calculateVerticalLeftLabels() {
        guard let minGlucoseValue = glucoseEntries.map({ $0.value }).min() else { return }
        guard let maxGlucoseValue = glucoseEntries.map({ $0.value }).max() else { return }
        let adjustedMinValue = minGlucoseValue.rounded(.down)
        let adjustedMaxValue = maxGlucoseValue.rounded(.up)
        let step = (adjustedMaxValue - adjustedMinValue) / Double(verticalLines - 1)
        
        var labels: [String] = []
        for index in 0..<verticalLines {
            labels.append(String(format: "%0.f", adjustedMinValue + step * Double(index)))
        }
        
        leftLabelsView.labels = labels
        leftLabelsView.setNeedsDisplay()
        chartView.verticalLinesCount = labels.count
        if adjustedMinValue ~~ adjustedMaxValue {
            chartView.yRange = (adjustedMinValue - 1.0)...(adjustedMaxValue + 1.0)
        } else {
            chartView.yRange = adjustedMinValue...adjustedMaxValue
        }
    }
    
    private func calculateHorizontalBottomLabels() {
        var globalHorizontalLabels: [String] = []
        
        let interval = horizontalInterval(for: localDateRange.duration)

        let initialGridDate: Date
        let now = Date()
        
        if interval < .secondsPerHour {
            let currentMinute = Calendar.current.component(.minute, from: now)
            let targetMinute = Int((Double(currentMinute) / 10.0).rounded(.down) * 10.0)
            var components = Calendar.current.dateComponents(in: .current, from: now)
            components.minute = targetMinute
            components.second = 0
            components.nanosecond = 0
            initialGridDate = Calendar.current.date(from: components) ?? now
        } else {
            var components = Calendar.current.dateComponents(in: .current, from: now)
            components.minute = 0
            components.second = 0
            components.nanosecond = 0
            initialGridDate = Calendar.current.date(from: components) ?? now
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var endGridTime = initialGridDate.timeIntervalSince1970
        while endGridTime > globalDateRange.start.timeIntervalSince1970 {
            let date = Date(timeIntervalSince1970: endGridTime)
            globalHorizontalLabels.append(dateFormatter.string(from: date))
            endGridTime -= interval
        }
        
        chartView.horizontalLabels = globalHorizontalLabels.reversed()
        chartView.relativeHorizontalStartingOffset = CGFloat(
            (endGridTime + interval - globalDateRange.start.timeIntervalSince1970) / globalDateRange.duration
        )
        chartView.relativeHorizontalInterval = CGFloat(interval / globalDateRange.duration)
    }
    
    private func horizontalInterval(for localInterval: TimeInterval) -> TimeInterval {
        let hours = Int((localInterval / .secondsPerHour).rounded())
        switch hours {
        case 0...1: return 10.0 * .secondsPerMinute
        case 2...11: return .secondsPerHour
        case 12...23: return .secondsPerHour * 3.0
        case 24: return .secondsPerHour * 4.0
        default: return TimeInterval(hours) / 4.0 * .secondsPerHour
        }
    }
    
    private func updateDetailLabel() {
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

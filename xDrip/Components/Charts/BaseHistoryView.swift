//
//  BaseHistoryView.swift
//  xDrip
//
//  Created by Dmitry on 6/24/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class BaseHistoryView: UIView {
    let verticalLines: Int = 5
    var forwardTimeOffset: TimeInterval = 600.0
    
    let scrollContainer = ChartScrollContainer()
    let detailsView = ChartEntryDetailView()
    let leftLabelsView = ChartVerticalLabelsView()
    var chartView = BaseChartView()
    weak var chartWidthConstraint: NSLayoutConstraint?
    
    var entries: [BaseChartEntry] = []
    
    var globalDateRange = DateInterval()
    var localDateRange = DateInterval()
    var localInterval: TimeInterval = .secondsPerHour
    var userRelativeSelection: CGFloat?
    var unit = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
   private func commonInit() {
        setupViews()
        setupScrolling()
        setTimeFrame(.secondsPerHour)
    }
    
    func setupViews() {
        isOpaque = false
        backgroundColor = .background1
        
        addSubview(detailsView)
        addSubview(leftLabelsView)
        addSubview(scrollContainer)
        scrollContainer.scrollView.addSubview(chartView)
        
        detailsView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
        detailsView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor).isActive = true
        detailsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        detailsView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true

        leftLabelsView.topAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
        leftLabelsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftLabelsView.trailingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
        leftLabelsView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        scrollContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        scrollContainer.topAnchor.constraint(equalTo: detailsView.bottomAnchor).isActive = true
        
        chartView.bindToSuperview()
        chartView.heightAnchor.constraint(equalTo: scrollContainer.heightAnchor, multiplier: 1.0).isActive = true
        let chartViewWidth = chartView.widthAnchor.constraint(equalToConstant: bounds.width)
        chartViewWidth.isActive = true
        chartWidthConstraint = chartViewWidth
    }
    
    func setupSeparator(bottomView: UIView) {
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
        setupOnRelativeOffsetChanged()
        setupOnSelectionChanged()
    }
    
    func setupOnRelativeOffsetChanged() {}
    
    private func setupOnSelectionChanged() {
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
    func setup(with entries: [BaseChartEntry], unit: String) {
        var entries : [HomeGlucoseEntry] = [
            HomeGlucoseEntry(
                value: 62,
                date:  Date() - 2000,
                severity: GlucoseChartSeverityLevel.normal
            ),
            HomeGlucoseEntry(
                value: 60,
                date:  Date() - 1000,
                severity: GlucoseChartSeverityLevel.normal
            ),
            /*HomeGlucoseEntry(
                value: 61,
                date:  Date(),
                severity: GlucoseChartSeverityLevel.normal
            )*/
        ]
        self.unit = unit
        self.entries = entries
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
    
    func updateChart() {
        calculateVerticalLeftLabels()
        calculateHorizontalBottomLabels()
        
        let scrollSegments = CGFloat(
            (globalDateRange.duration - forwardTimeOffset) / (localDateRange.duration - forwardTimeOffset)
        )
        let chartWidth = scrollContainer.bounds.width * scrollSegments
        chartWidthConstraint?.constant = chartWidth
        
        chartView.entries = entries
        chartView.dateInterval = globalDateRange
        chartView.setNeedsDisplay()
        
        updateChartSliderView(with: scrollSegments)
        
        scrollContainer.layoutIfNeeded()
        scrollContainer.scrollView.contentOffset = CGPoint(x: chartWidth - scrollContainer.bounds.width, y: 0.0)
    }
    
    func updateChartSliderView(with scrollSegments: CGFloat) {
    }
    
   private func calculateVerticalLeftLabels() {
        guard let minGlucoseValue = entries.map({ $0.value }).min() else { return }
        guard let maxGlucoseValue = entries.map({ $0.value }).max() else { return }
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
    
    private func nearestEntry(forDate date: Date) -> BaseChartEntry? {
        let maxDiff: TimeInterval = .secondsPerMinute * 5.0
        
        if entries.isEmpty {
            return nil
        } else if entries.count == 1 {
            let diff = abs(date.timeIntervalSince1970 - entries[0].date.timeIntervalSince1970)
            return diff <= maxDiff ? entries[0] : nil
        }
        
        let diffs = entries.map { abs(date.timeIntervalSince1970 - $0.date.timeIntervalSince1970) }
        var minDiff = Double.greatestFiniteMagnitude
        var minDiffIndex = 0
        for (index, diff) in diffs.enumerated() where diff < minDiff {
            minDiff = diff
            minDiffIndex = index
        }
        
        return minDiff <= maxDiff ? entries[minDiffIndex] : nil
    }
}

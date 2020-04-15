//
//  GlucoseHistoryView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

enum GlucoseChartSeverityLevel {
    case low
    case normal
    case high
}

protocol GlucoseChartGlucoseEntry {
    var value: Double { get }
    var date: Date { get }
    var severity: GlucoseChartSeverityLevel { get }
}

extension DateInterval {
    init(endDate: Date, duration: TimeInterval) {
        let startDate = Date(timeIntervalSince1970: endDate.timeIntervalSince1970 - duration)
        self.init(start: startDate, end: endDate)
    }
}

final class GlucoseHistoryView: UIView {
    private let verticalLines: Int = 5
    
    private let scrollContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let leftLabelsView = ChartVerticalLabelsView()
    private let chartView = GlucoseChartView()
    private let chartScrollView = ChartScrollView()
    private weak var chartWidthConstraint: NSLayoutConstraint?
    
    private var glucoseEntries: [GlucoseChartGlucoseEntry] = []
    
    var globalDateRange: DateInterval = DateInterval(endDate: Date() + 600.0, duration: 86400.0 + 600.0)
    var localDateRange: DateInterval = DateInterval(endDate: Date() + 600.0, duration: 3600.0 + 600.0)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
        setupScrolling()
        setupDummy()
    }
    
    private func setupViews() {
        isOpaque = false
        
        addSubview(leftLabelsView)
        addSubview(scrollContainer)
        scrollContainer.addSubview(chartView)
        addSubview(chartScrollView)
        
        chartScrollView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        chartScrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartScrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        chartScrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        leftLabelsView.bottomAnchor.constraint(equalTo: chartScrollView.topAnchor).isActive = true
        leftLabelsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftLabelsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftLabelsView.trailingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
        leftLabelsView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        scrollContainer.bottomAnchor.constraint(equalTo: chartScrollView.topAnchor).isActive = true
        scrollContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        scrollContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
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
        
    }
    
    /// Should be sorted by date ascending
    func setup(with entries: [GlucoseChartGlucoseEntry]) {
        glucoseEntries = entries
        calculateVerticalLeftLabels()
        calculateHorizontalBottomLabels()
        
        let scrollSegments = CGFloat(globalDateRange.duration / localDateRange.duration)
        let chartWidth = bounds.width * scrollSegments
        chartWidthConstraint?.constant = chartWidth
        
        chartView.entries = entries
        chartView.dateInterval = globalDateRange
        
        chartScrollView.currentRelativeOffset = (scrollSegments - 1.0) / scrollSegments
        chartScrollView.sliderRelativeWidth = 1.0 / scrollSegments
        chartScrollView.entries = entries
        chartScrollView.dateInterval = globalDateRange
        chartScrollView.yRange = chartView.yRange
        
        scrollContainer.layoutIfNeeded()
        scrollContainer.contentOffset = CGPoint(x: chartWidth - scrollContainer.bounds.width, y: 0.0)
    }
    
    private func calculateVerticalLeftLabels() {
        guard let minGlucoseValue = glucoseEntries.map({ $0.value }).min() else { return }
        guard let maxGlucoseValue = glucoseEntries.map({ $0.value }).max() else { return }
        let adjustedMinValue = minGlucoseValue.rounded(.down)
        let adjustedMaxValue = maxGlucoseValue.rounded(.up)
        let step = (adjustedMaxValue - adjustedMinValue) / Double(verticalLines - 1)
        
        var labels: [String] = []
        for i in 0..<verticalLines {
            labels.append(String(format: "%g", adjustedMinValue + step * Double(i)))
        }
        
        leftLabelsView.labels = labels
        chartView.verticalLinesCount = labels.count
        chartView.yRange = adjustedMinValue...adjustedMaxValue
    }
    
    private func calculateHorizontalBottomLabels() {
        var globalHorizontalLabels: [String] = []
        
        let hours = Int((localDateRange.duration / 3600.0).rounded())
        let considerMinutes = hours <= 1
        let interval = considerMinutes ? 600.0 : (hours >= 12 ? 10800.0 : 3600.0)

        let initialGridDate: Date
        let now = Date()
        
        if considerMinutes {
            let currentMinute = Calendar.current.component(.minute, from: now)
            let targetMinute = Int((Double(currentMinute) / 10.0).rounded(.down) * 10.0)
            var components = Calendar.current.dateComponents(in: .current, from: now)
            components.minute = targetMinute
            components.second = 0
            components.nanosecond = 0
            initialGridDate = Calendar.current.date(from: components) ?? now
        } else {
            guard let targetDate = Calendar.current.date(bySetting: .minute, value: 0, of: now) else { return }
            initialGridDate = Calendar.current.date(bySetting: .second, value: 0, of: targetDate) ?? Date()
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
    
    private func setupDummy() {
        let now = Date().timeIntervalSince1970
        let count = 400
        var entries: [DummyEntry] = []
        var previous: Double = 10.0
        var modifier: Double = 1.0
        for i in 0..<count {
            previous += modifier
            if previous == 15.0 {
                modifier = -1
            } else if previous == 10.0 {
                modifier = 1.0
            }
            let date = Date(timeIntervalSince1970: now - Double(i) * (86400.0 / Double(count)))
            let severity: GlucoseChartSeverityLevel
            switch previous {
            case 0.0...8.0: severity = .low
            case 8.0...12.0: severity = .normal
            default: severity = .high
            }
            entries.append(DummyEntry(value: previous, date: date, severity: severity))
        }
        
        setup(with: entries.reversed())
    }
    
    private struct DummyEntry: GlucoseChartGlucoseEntry {
        let value: Double
        let date: Date
        let severity: GlucoseChartSeverityLevel
    }
}

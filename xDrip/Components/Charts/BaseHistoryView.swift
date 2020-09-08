//
//  BaseHistoryView.swift
//  xDrip
//
//  Created by Dmitry on 6/24/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class BaseHistoryView: UIView {
    var verticalLines: Int = 5
    var forwardTimeOffset: TimeInterval = 600.0
    
    let scrollContainer = ChartScrollContainer()
    let leftLabelsView = ChartVerticalLabelsView()
    var chartView = BaseChartView()
    weak var chartWidthConstraint: NSLayoutConstraint?
    
    var globalDateRange = DateInterval()
    var localDateRange = DateInterval()
    var localInterval: TimeInterval = .secondsPerHour
    var globalInterval: TimeInterval = .secondsPerDay
    var globalDate: Date?
    var userRelativeSelection: CGFloat?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupViews()
        setupScrolling()
        setLocalTimeFrame(.secondsPerHour)
    }
    
    func setupViews() {
        isOpaque = false
        addSubview(leftLabelsView)
        addSubview(scrollContainer)
        scrollContainer.scrollView.addSubview(chartView)
        leftLabelsView.topAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
        leftLabelsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        leftLabelsView.trailingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
        leftLabelsView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
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
            self.updateDetailView(with: relativeOffset)
        }
    }
    
    func updateDetailView(with relativeOffset: CGFloat) {
    }
    
    func setLocalTimeFrame(_ localInterval: TimeInterval) {
        self.localInterval = localInterval
        forwardTimeOffset = horizontalInterval(for: localInterval)
        scrollContainer.hideDetailView()
        update()
    }
    
    func setGlobalTimeFrame(_ globalInterval: TimeInterval) {
        self.globalInterval = globalInterval
        scrollContainer.hideDetailView()
        update()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
        scrollContainer.hideDetailView()
    }
    
    func update() {
        updateIntervals()
        updateChart()
    }
    
    private func updateIntervals() {
        var endDate = Date() + forwardTimeOffset
        var globalDuration = globalInterval + forwardTimeOffset
        var localDuration = localInterval + forwardTimeOffset
        
        if let date = globalDate {
            endDate = Calendar.current.startOfDay(for: date) + .secondsPerDay
            globalDuration = globalInterval
            localDuration = localInterval
        }
        
        globalDateRange = DateInterval(endDate: endDate, duration: globalDuration)
        localDateRange = DateInterval(endDate: globalDateRange.end, duration: localDuration)
    }
    
    func updateChart() {
        calculateHorizontalBottomLabels()
        
        let scrollSegments = max(
            CGFloat(
                (globalDateRange.duration - forwardTimeOffset) / (localDateRange.duration - forwardTimeOffset)
            ),
            1.0
        )
        let chartWidth = scrollContainer.bounds.width * scrollSegments
        chartWidthConstraint?.constant = chartWidth
        chartView.dateInterval = globalDateRange
        chartView.setNeedsDisplay()
        updateChartSliderView(with: scrollSegments)
        scrollContainer.layoutIfNeeded()
        scrollContainer.scrollView.contentOffset = CGPoint(x: chartWidth - scrollContainer.bounds.width, y: 0.0)
    }
    
    func updateChartSliderView(with scrollSegments: CGFloat) {
    }
    
    func calculateVerticalLeftLabels(minValue: Double?, maxValue: Double?) {
        guard let minValue = minValue else { return }
        guard let maxValue = maxValue else { return }
        let adjustedMinValue = max(minValue.rounded(.down), 0.0)
        let adjustedMaxValue = maxValue.rounded(.up)
        let step = (adjustedMaxValue - adjustedMinValue) / Double(verticalLines - 1)
        
        var labels: [String] = []
        for index in 0..<verticalLines {
            labels.append(String(format: "%0.f", adjustedMinValue + step * Double(index)))
        }
        
        leftLabelsView.labels = labels
        leftLabelsView.setNeedsDisplay()
        chartView.verticalLinesCount = labels.count
        if adjustedMinValue ~~ adjustedMaxValue {
            chartView.yRange = (max(adjustedMinValue - 1.0, 0.0))...(adjustedMaxValue + 1.0)
        } else {
            chartView.yRange = adjustedMinValue...adjustedMaxValue
        }
    }
    
    private func calculateHorizontalBottomLabels() {
        var globalHorizontalLabels: [String] = []
        
        let interval = horizontalInterval(for: localDateRange.duration)
        
        let initialGridDate: Date
        let now = globalDate != nil ? globalDateRange.end : Date()
        
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
            let currentHour = Calendar.current.component(.hour, from: now)
            let targetHour = Int((Double(currentHour) / interval.hours).rounded(.down) * interval.hours)
            components.hour = targetHour
            components.minute = 0
            components.second = 0
            components.nanosecond = 0
            initialGridDate = Calendar.current.date(from: components) ?? now
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let hoursFormatter = DateFormatter()
        hoursFormatter.dateFormat = "HH:mm"
        
        var endGridTime = initialGridDate.timeIntervalSince1970
        while endGridTime > globalDateRange.start.timeIntervalSince1970 {
            let date = Date(timeIntervalSince1970: endGridTime)
            let stringDate = hoursFormatter.string(from: date)
            
            if stringDate == "00:00" {
                globalHorizontalLabels.append(dateFormatter.string(from: date))
            } else {
                globalHorizontalLabels.append(stringDate)
            }
            
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
        default: return .secondsPerHour * 3.0
        }
    }
}

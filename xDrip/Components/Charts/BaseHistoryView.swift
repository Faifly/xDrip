//
//  BaseHistoryView.swift
//  xDrip
//
//  Created by Dmitry on 6/24/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class BaseHistoryView: UIView {
    var maxVerticalLinesCount = 5
    
    var forwardTimeOffset: TimeInterval = 600.0
    
    let scrollContainer = ChartScrollContainer()
    let leftLabelsView = ChartVerticalLabelsView()
    var chartView = BaseChartView()
    var multiplier = CGFloat(1.6)
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
        leftLabelsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
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
    
    func updateIntervals() {
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
    
    func updateChart(respectScreenWidth: Bool = false) {
        calculateHorizontalBottomLabels()
        
        let scrollSegments = max(
            CGFloat(
                (globalDateRange.duration - forwardTimeOffset) / (localDateRange.duration - forwardTimeOffset)
            ),
            1.0
        )
        var chartWidth = scrollContainer.bounds.width * scrollSegments
        if respectScreenWidth {
            #if os(iOS)
            let width = UIScreen.main.bounds.width
            if width < 414.0 {
                multiplier = 1.6 + (414.0 / width) - 1
            }
            #endif
            chartWidth *= multiplier
        }
        chartWidthConstraint?.constant = chartWidth
        chartView.dateInterval = globalDateRange
        chartView.setNeedsDisplay()
        updateChartSliderView(with: scrollSegments * multiplier)
        scrollContainer.layoutIfNeeded()
        scrollContainer.scrollView.contentOffset = CGPoint(x: chartWidth - scrollContainer.bounds.width, y: 0.0)
    }
    
    func updateChartSliderView(with scrollSegments: CGFloat) {
    }
    
    func calculateVerticalLeftLabels(minValue: Double?, maxValue: Double?) {
        guard var minValue = minValue else { return }
        guard var maxValue = maxValue else { return }
        let unit = User.current.settings.unit
        
        if unit == .mgDl {
            minValue = minValue.rounded(.down)
            maxValue = maxValue.rounded(.up)
        }
        
        minValue *= 10.0
        maxValue *= 10.0
        
        minValue = minValue.rounded(.down)
        maxValue = maxValue.rounded(.up)
        
        let alphaValue = 0.20 * (maxValue - minValue)
        var adjustedMinValue = max((minValue - alphaValue).rounded(.down), 0.0)
        var adjustedMaxValue = (maxValue + alphaValue).rounded(.up)
        if (adjustedMinValue / 10.0) ~~ (adjustedMaxValue / 10.0) {
            adjustedMinValue = max(adjustedMinValue - 10.0, 0.0)
            adjustedMaxValue += 10.0
        }
        
        let diff = adjustedMaxValue - adjustedMinValue
        var verticalLines: Int
        if Int(diff / 10) < maxVerticalLinesCount - 1 {
            verticalLines = Int(diff / 10) + 1
        } else {
            verticalLines = maxVerticalLinesCount
        }
        
        let tail = Int(diff) % (verticalLines - 1)
        if tail != 0 {
            adjustedMaxValue += Double((verticalLines - 1) - tail)
        }
        
        let step = (diff / Double(verticalLines - 1)).rounded()
        
        var labels: [String] = []
        let format = unit == .mmolL ? "%0.1f" : "%0.f"
        for index in 0..<verticalLines {
            labels.append(String(format: format, (adjustedMinValue + step * Double(index)) / 10.0))
        }
        
        leftLabelsView.labels = labels
        leftLabelsView.setNeedsDisplay()
        chartView.verticalLinesCount = labels.count

        chartView.yRange = (adjustedMinValue / 10.0)...(adjustedMaxValue / 10.0)
    }
    
    private func calculateHorizontalBottomLabels() {
        var globalHorizontalLabels: [String] = []
        
        let interval = horizontalInterval(for: localDateRange.duration)
        
        let initialGridDate: Date
        let now = globalDate != nil ? globalDateRange.end : Date()
        
        if interval < .secondsPerHour {
            let currentMinute = Calendar.current.component(.minute, from: now)
            let targetMinute = Int((Double(currentMinute) / 10.0).rounded(.up) * 10.0)
            var components = Calendar.current.dateComponents(in: .current, from: now)
            components.minute = targetMinute
            components.second = 0
            components.nanosecond = 0
            initialGridDate = Calendar.current.date(from: components) ?? now
        } else {
            var components = Calendar.current.dateComponents(in: .current, from: now)
            let currentHour = Calendar.current.component(.hour, from: now)
            let targetHour = Int((Double(currentHour + 1) / interval.hours).rounded(.up) * interval.hours)
            components.hour = targetHour
            components.minute = 0
            components.second = 0
            components.nanosecond = 0
            initialGridDate = Calendar.current.date(from: components) ?? now
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let hoursFormatter = DateFormatter()
        hoursFormatter.dateFormat = "H:mm"
        
        var endGridTime = initialGridDate.timeIntervalSince1970
        while endGridTime > globalDateRange.start.timeIntervalSince1970 {
            let date = Date(timeIntervalSince1970: endGridTime)
            let stringDate = hoursFormatter.string(from: date)
            
            if stringDate == "0:00" || stringDate == "12:00 AM" {
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

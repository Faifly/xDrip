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
    weak var chartWidthConstraint: NSLayoutConstraint?
    
    private var timer: Timer?
    var detailsView: ChartEntryDetailView?
    
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
    
    func startCheckTimer() {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { [weak self] _ in
            self?.hideDetailView()
        })
    }
    
    func hideDetailView() {
        detailsView?.setHidden(true)
        scrollContainer.hideDetailView()
    }
    
    func showDetailView() {
        detailsView?.setHidden(false)
        scrollContainer.showDetailView()
    }
    
    func setupViews() {
        isOpaque = false
        addSubview(leftLabelsView)
        addSubview(scrollContainer)
        scrollContainer.scrollView.addSubview(chartView)
        leftLabelsView.topAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
        leftLabelsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
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
    
    func setupOnSelectionChanged() {}
    
    func updateDetailView(with relativeOffset: CGFloat) {
    }
    
    func setLocalTimeFrame(_ localInterval: TimeInterval) {
        self.localInterval = localInterval
        forwardTimeOffset = horizontalInterval(for: localInterval)
        hideDetailView()
        update()
    }
    
    func setGlobalTimeFrame(_ globalInterval: TimeInterval) {
        self.globalInterval = globalInterval
        hideDetailView()
        update()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
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
        
    func calculateVerticalLeftLabels(minValue: Double?, maxValue: Double?, isForGlucose: Bool = true) {
        guard let minValue = minValue else { return }
        guard let maxValue = maxValue else { return }
        var labels: [String] = []
        let adjustedMinValue: Int
        let adjustedMaxValue: Int

        let unit = User.current.settings.unit
        let useMinimalStep = !isForGlucose || (unit == .mmolL)
        
        let verticalPadding = useMinimalStep ? 1 : 10
        let maxV = Int(maxValue.rounded(.up))
        let minV = Int(minValue.rounded(.down))
        adjustedMinValue = max((useMinimalStep ? minV : minV.roundedDown) - verticalPadding, 0)
        let linesCount = max(((maxV - minV) / verticalPadding) + 1, 2)
        let adjustedLinesCount = min(linesCount, maxVerticalLinesCount)
        let diff = (maxV + verticalPadding) - adjustedMinValue
        let step = Int((Double(diff) / Double((adjustedLinesCount - 1))).rounded(.up))
        let adjustedStep = (useMinimalStep ? step : step.roundedUp)
        adjustedMaxValue = adjustedMinValue + (adjustedStep * (adjustedLinesCount - 1))

        let format = useMinimalStep && isForGlucose ? "%0.1f" : "%0.f"
        for index in 0..<adjustedLinesCount {
            labels.append(String(format: format, Double(adjustedMinValue + (adjustedStep * index))))
        }
        
        leftLabelsView.labels = labels
        leftLabelsView.setNeedsDisplay()
        chartView.verticalLinesCount = labels.count

        chartView.yRange = Double(adjustedMinValue)...Double(adjustedMaxValue)
    }
    
    private func calculateHorizontalBottomLabels() {
        var globalHorizontalLabels: [ChartBottomLabel] = []
        
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
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd")
        let hoursFormatter = DateFormatter()
        hoursFormatter.dateFormat = localInterval > .secondsPerHour ? "H" : "H:mm"
        
        var endGridTime = initialGridDate.timeIntervalSince1970
        while endGridTime > globalDateRange.start.timeIntervalSince1970 {
            let date = Date(timeIntervalSince1970: endGridTime)
            
            let calendar = NSCalendar.current
            let unitFlags: Set<Calendar.Component> = [.hour, .minute]
            let components = calendar.dateComponents(unitFlags, from: date)
    
            if components.hour == 0, components.minute == 0, localInterval > .secondsPerHour {
                globalHorizontalLabels.append(ChartBottomLabel(title: dateFormatter.string(from: date),
                                                               isCentered: true))
            } else {
                globalHorizontalLabels.append(ChartBottomLabel(title: hoursFormatter.string(from: date)))
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
        case 12...23: return .secondsPerHour * 3.0
        default: return .secondsPerHour * 4.0
        }
    }
}

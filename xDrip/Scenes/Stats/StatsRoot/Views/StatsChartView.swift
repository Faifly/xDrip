//
//  StatsChartView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 19.07.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class StatsChartView: UIView {
    let linesChart = StatsBarsChart()
    private let verticalLabelsView = ChartVerticalLabelsView()
    private let detailsView = ChartEntryDetailView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        if #available(iOS 13.0, *) {
            backgroundColor = .systemGroupedBackground
        } else {
            backgroundColor = .background1
        }
        
        verticalLabelsView.backgroundColor = .clear
        verticalLabelsView.font = .systemFont(ofSize: 11.0, weight: .regular)
        
        addSubview(linesChart)
        addSubview(verticalLabelsView)
        addSubview(detailsView)
        
        NSLayoutConstraint.activate([
            detailsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            detailsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28.0),
            detailsView.topAnchor.constraint(equalTo: topAnchor),
            detailsView.bottomAnchor.constraint(equalTo: linesChart.topAnchor),
            detailsView.heightAnchor.constraint(equalToConstant: 60.0),
            verticalLabelsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6.0),
            verticalLabelsView.trailingAnchor.constraint(equalTo: linesChart.leadingAnchor, constant: -4.0),
            verticalLabelsView.topAnchor.constraint(equalTo: detailsView.bottomAnchor),
            verticalLabelsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalLabelsView.widthAnchor.constraint(equalToConstant: 32.0),
            linesChart.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.0),
            linesChart.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        linesChart.onSelectionChange = { [weak self] selectedIndex in
            self?.onChartSelectionChanged(index: selectedIndex)
        }
        
        detailsView.containerView.backgroundColor = .statsChartSelection
    }
    
    func update(with data: [StatsChartEntry]) {
        linesChart.entries = data
        let unit = User.current.settings.unit
        
        var labels: [String] = []
        let format = unit == .mmolL ? "%0.1f" : "%0.f"
        for index in 0..<linesChart.verticalCount {
            labels.append(String(format: format, Double(linesChart.visualMinValue + (linesChart.visualStep * index))))
        }
        verticalLabelsView.labels = labels
        
        linesChart.setNeedsDisplay()
        verticalLabelsView.setNeedsDisplay()
    }
    
    private func onChartSelectionChanged(index: Int?) {
        guard let index = index, index < linesChart.entries.count && index >= 0 else {
            detailsView.setHidden(true)
            return
        }
        let entry = linesChart.entries[index]
        detailsView.setHidden(!entry.hasValue)
        detailsView.setRelativeOffset(CGFloat(index) / CGFloat(linesChart.entries.count))
        
        guard let value = entry.value else { return }
        
        let minValue = String(format: "%0.1f", GlucoseUnit.convertFromDefault(value.lowerBound))
        let maxValue = String(format: "%0.1f", GlucoseUnit.convertFromDefault(value.upperBound))
        let medianValue = GlucoseUnit.convertFromDefault((value.upperBound + value.lowerBound) / 2.0)
        let median = String(format: "%0.1f \("stats_median_details_label".localized)", medianValue)
        let dateString = DateFormatter.localizedString(
            from: entry.interval.start,
            dateStyle: .short,
            timeStyle: .none
        )
        detailsView.setText(
            topLeft: "\(minValue) - \(maxValue)",
            topRight: User.current.settings.unit.label,
            bottom: "\(median), \(dateString)"
        )
    }
}

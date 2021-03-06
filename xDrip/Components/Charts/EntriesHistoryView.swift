//
//  EntriesHistoryView.swift
//  xDrip
//
//  Created by Dmitry on 6/23/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class EntriesHistoryView: BaseHistoryView {
    private var entriesChartView = EntriesChartView()
    private var chartEntries: [BaseChartEntry] = []
    private let chartTitleLabel = UILabel()
    private let chartButton = UIButton()
    private let noDataView = UIView()
    private let noDataLabel = UILabel()
    var onChartButtonClicked: () -> Void = {}
    
    override var chartView: BaseChartView {
        get {
            return entriesChartView
        }
        set {
            entriesChartView = newValue as? EntriesChartView ?? EntriesChartView()
        }
    }
    
    override var maxVerticalLinesCount: Int {
        get {
            return 3
        }
        set {
            super.maxVerticalLinesCount = newValue
        }
    }
    
    override func setupViews() {
        backgroundColor = .clear
        super.setupViews()
        scrollContainer.isUserInteractionEnabled = false
        leftLabelsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chartTitleLabel.backgroundColor = .clear
        chartTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addSubview(chartTitleLabel)
        chartTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        chartTitleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chartTitleLabel.bottomAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
        chartTitleLabel.heightAnchor.constraint(equalToConstant: 49.0).isActive = true
        scrollContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        chartButton.translatesAutoresizingMaskIntoConstraints = false
        chartButton.setTitleColor(.chartButtonTextColor, for: .normal)
        chartButton.setTitleColor(.chartButtonHighlitedTextColor, for: .highlighted)
        chartButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        chartButton.addTarget(self, action: #selector(self.chartButtonClicked), for: .touchUpInside)
        addSubview(chartButton)
        chartButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
        chartButton.leadingAnchor.constraint(greaterThanOrEqualTo: chartTitleLabel.trailingAnchor,
                                             constant: 5).isActive = true
        chartButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chartButton.bottomAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
        
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.backgroundColor = .dimView
        scrollContainer.addSubview(noDataView)
        noDataView.bindToSuperview()
        
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.backgroundColor = .clear
        noDataLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        noDataLabel.textColor = .chartButtonTextColor
        noDataLabel.textAlignment = .center
        noDataLabel.text = "home_no_data_for_period".localized
        noDataView.addSubview(noDataLabel)
        noDataLabel.leadingAnchor.constraint(equalTo: noDataView.leadingAnchor).isActive = true
        noDataLabel.trailingAnchor.constraint(equalTo: noDataView.trailingAnchor).isActive = true
        noDataLabel.topAnchor.constraint(equalTo: noDataView.centerYAnchor,
                                         constant: -bounds.height / 5).isActive = true
            }
    
    override func updateChart() {
        super.calculateVerticalLeftLabels(minValue: chartEntries.map({ $0.value }).min(),
                                          maxValue: chartEntries.map({ $0.value }).max(),
                                          isForGlucose: false)
        super.updateChart()
    }
    
    func setup(with viewModel: BaseFoodEntryViewModel) {
        isHidden = !viewModel.isShown
        chartEntries = viewModel.entries
        entriesChartView.entries = viewModel.entries
        entriesChartView.color = viewModel.color
        chartTitleLabel.text = viewModel.chartTitle
        updateChartVisibilityAndButtonTitle(viewModel.chartButtonTitle, viewModel.isChartShown)
        super.update()
    }
    
    func setTimeFrame(_ localInterval: TimeInterval, chartButtonTitle: String, showChart: Bool) {
        super.setLocalTimeFrame(localInterval)
        updateChartVisibilityAndButtonTitle(chartButtonTitle, showChart)
    }
    
    private func updateChartVisibilityAndButtonTitle(_ chartButtonTitle: String, _ showChart: Bool) {
        chartButton.setTitle(chartButtonTitle, for: .normal)
        noDataView.isHidden = showChart
        leftLabelsView.isHidden = !showChart
    }
    
    override func updateIntervals() {
        super.updateIntervals()
        if localInterval < .secondsPerDay {
         localDateRange.duration += forwardTimeOffset
        }
    }
    
    @objc func chartButtonClicked() {
        onChartButtonClicked()
    }
}

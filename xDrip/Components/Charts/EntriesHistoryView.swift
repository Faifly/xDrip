//
//  EntriesHistoryView.swift
//  xDrip
//
//  Created by Dmitry on 6/23/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class EntriesHistoryView: BaseHistoryView {
    var entriesChartView = EntriesChartView()
    var chartEntries: [BaseChartEntry] = []
    let chartTitleLabel = UILabel()
    let chartButton = UIButton()
    var onButtonClicked: () -> Void = {}
    
    override var chartView: BaseChartView {
        get {
            return entriesChartView
        }
        set {
            entriesChartView = newValue as? EntriesChartView ?? EntriesChartView()
        }
    }
    
    override var entries: [BaseChartEntry] {
        get {
            return chartEntries
        }
        set {
            chartEntries = newValue.count < 2 ? [] : newValue
        }
    }
    
    override func setupViews() {
        super.setupViews()
        leftLabelsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        chartTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chartTitleLabel.backgroundColor = .clear
        chartTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addSubview(chartTitleLabel)
        chartTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        chartTitleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chartTitleLabel.bottomAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
    
        chartButton.translatesAutoresizingMaskIntoConstraints = false
        chartButton.setTitleColor(.chartButtonTextColor, for: .normal)
        chartButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        chartButton.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        addSubview(chartButton)
        chartButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
        chartButton.leadingAnchor.constraint(greaterThanOrEqualTo: chartTitleLabel.trailingAnchor, constant: 5).isActive = true
        chartButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chartButton.bottomAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
    }
    
    override func updateChart() {
        super.updateChart()
    }
    
    func setup(with viewModel: Home.EntriesDataUpdate.ViewModel) {
        super.setup(with: viewModel.entries, unit: viewModel.unit)
        entriesChartView.color = viewModel.color
        chartTitleLabel.text = viewModel.chartTitle
        chartButton.setTitle(viewModel.chartButtonTitle, for: .normal)
    }
    
    @objc func buttonClicked() {
        print("Button Clicked")
        onButtonClicked()
    }
}

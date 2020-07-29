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
    var onButtonClicked: () -> Void = {}
    
    override var chartView: BaseChartView {
        get {
            return entriesChartView
        }
        set {
            entriesChartView = newValue as? EntriesChartView ?? EntriesChartView()
        }
    }
    
    override func setupViews() {
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
        chartTitleLabel.heightAnchor.constraint(equalToConstant: 58.0).isActive = true
        scrollContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        chartButton.translatesAutoresizingMaskIntoConstraints = false
        chartButton.setTitleColor(.chartButtonTextColor, for: .normal)
        chartButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        chartButton.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        addSubview(chartButton)
        chartButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14).isActive = true
        chartButton.leadingAnchor.constraint(greaterThanOrEqualTo: chartTitleLabel.trailingAnchor,
                                             constant: 5).isActive = true
        chartButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chartButton.bottomAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
    }
    
    override func updateChart() {
        calculateVerticalLeftLabels(minValue: chartEntries.map({ $0.value }).min(),
                                    maxValue: chartEntries.map({ $0.value }).max())
        super.updateChart()
    }
    
    func setup(with viewModel: BaseFoodEntryViewModel) {
        chartEntries = viewModel.entries
        entriesChartView.entries = viewModel.entries
        entriesChartView.color = viewModel.color
        chartTitleLabel.text = viewModel.chartTitle
        chartButton.setTitle(viewModel.chartButtonTitle, for: .normal)
        super.update()
    }
    
    @objc func buttonClicked() {
        print("Button Clicked")
        onButtonClicked()
    }
}

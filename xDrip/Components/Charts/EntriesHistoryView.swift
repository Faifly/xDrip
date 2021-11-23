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
    private var chartTriangles: [BaseChartTriangle] = []
    private var chartUnit = ""
    private let chartTitleLabel = UILabel()
    private let chartButton = UIButton()
    private let noDataView = UIView()
    private let noDataLabel = UILabel()
    var onChartButtonClicked: () -> Void = {}
    
    var onSelectionChanged: ((CGFloat) -> Void)?
    
    var detailsEnabled: Bool = true {
        didSet {
            setupDetailsView()
        }
    }
    
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
        setupDetailsView()
        leftLabelsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chartTitleLabel.backgroundColor = .clear
        chartTitleLabel.font = UIFont.systemFont(ofSize: min(UIScreen.main.bounds.width * 0.035, 16.0), weight: .medium)
        addSubview(chartTitleLabel)
        chartTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14).isActive = true
        chartTitleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chartTitleLabel.bottomAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
        chartTitleLabel.heightAnchor.constraint(equalToConstant: 49.0).isActive = true
        scrollContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -33.0).isActive = true
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
    
    func setupDetailsView() {
        if let detailsView = detailsView {
            NSLayoutConstraint.deactivate(detailsView.constraints)
            detailsView.removeFromSuperview()
        }

        if detailsEnabled {
            let detailsView = ChartEntryDetailView()
            addSubview(detailsView)
            detailsView.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor).isActive = true
            detailsView.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor).isActive = true
            detailsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            detailsView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
            self.detailsView = detailsView
        }
    }
    
    override func updateChart() {
        super.calculateVerticalLeftLabels(minValue: chartEntries.map({ $0.value }).min(),
                                          maxValue: chartEntries.map({ $0.value }).max(),
                                          isForGlucose: false)
        super.updateChart()
    }
        
    func setup(with viewModel: BaseFoodEntryViewModel) {
        isHidden = !viewModel.isShown
        
        let triangles = viewModel.entries
        var points = [BaseChartEntry]()
        
        for triangle in triangles {
            points.append(triangle.firstPoint)
            points.append(triangle.secondPoint)
            points.append(triangle.thirdPoint)
        }
        
        chartTriangles = triangles
        chartEntries = points
        entriesChartView.entries = points
        entriesChartView.color = viewModel.color
        chartTitleLabel.text = viewModel.chartTitle
        chartUnit = viewModel.chartUnit
        updateChartVisibilityAndButtonTitle(viewModel.chartUnit, viewModel.isChartShown)
        detailsView?.leftPadding = viewModel.detailViewPaddings.left
        detailsView?.rightPadding = viewModel.detailViewPaddings.right
        super.update()
    }
    
    private func updateChartVisibilityAndButtonTitle(_ unit: String, _ showChart: Bool) {
        let value = value(for: Date()) ?? 0.0
        let title = String(format: "%.2f", value.rounded(to: 2)) + " \(unit)" + " >"
        
        chartButton.setTitle(title, for: .normal)
        noDataView.isHidden = showChart
        leftLabelsView.isHidden = !showChart
    }
    
    @objc func chartButtonClicked() {
        onChartButtonClicked()
    }
    
    func onRelativeOffsetChanged(_ offset: Double) {
        let contentWidth = self.scrollContainer.scrollView.contentSize.width
        let maxPossibleOffset = (contentWidth - self.scrollContainer.bounds.width) / contentWidth
        scrollContainer.scrollView.contentOffset = CGPoint(
            x: contentWidth * offset + 30.0 * offset / maxPossibleOffset,
            y: 0.0
        )
        updateDetailLabel()
    }
    
    override func setupOnSelectionChanged() {
        scrollContainer.onSelectionChanged = { [weak self] relativeOffset in
            guard let self = self else { return }
            self.onSelectionChanged(relativeOffset)
            self.onSelectionChanged?(relativeOffset)
        }
    }
    
    func onSelectionChanged(_ relativeOffset: CGFloat) {
        self.userRelativeSelection = relativeOffset
        self.updateDetailView(with: relativeOffset)
    }
    
    override func updateDetailView(with relativeOffset: CGFloat) {
        updateDetailLabel()
        detailsView?.setRelativeOffset(relativeOffset)
        scrollContainer.updateSelectionIndicator(relativeOffcet: relativeOffset)
    }
    
    func updateDetailLabel() {
        guard detailsEnabled else { return }
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
        
        if let value = value(for: selectedDate) {
            detailsView?.set(value: value, unit: chartUnit, date: selectedDate)
            showDetailView()
            startCheckTimer()
        } else {
            hideDetailView()
        }
    }
    
    private func value(for selectedDate: Date) -> Double? {
        let triangles = chartTriangles.filter({ selectedDate >= $0.secondPoint.date &&
                                                selectedDate <= $0.thirdPoint.date })
        
        let values = triangles.map({ calculatePointYFor(pointX: selectedDate,
                                                        startX: $0.secondPoint.date,
                                                        startY: $0.secondPoint.value,
                                                        endX: $0.thirdPoint.date) })
        
        return values.max()
    }
    
    private func calculatePointYFor(pointX: Date,
                                    startX: Date,
                                    startY: Double,
                                    endX: Date) -> Double {
        let pointX = pointX.timeIntervalSince1970
        let startX = startX.timeIntervalSince1970
        let endX = endX.timeIntervalSince1970
        
        return ((pointX - startX) * (0.0 - startY)) / (endX - startX) + startY
    }
}

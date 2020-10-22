//
//  ChartScrollView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class ChartSliderView: UIView, GlucoseChartProvider {
    private let chartInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
    var insets: UIEdgeInsets {
        return chartInsets
    }
    
    let circleSide: CGFloat = 4.0
    private let yMargin: CGFloat = 1.0
    
    private lazy var slider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .chartSliderBackground
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.chartGridLineColor.cgColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var glucoseEntries: [GlucoseChartGlucoseEntry] = []
    var basalEntries: [BasalChartBasalEntry] = []
    var dateInterval = DateInterval()
    var yRange: ClosedRange<Double> = 0.0...0.0
    
    var minDate: TimeInterval = 0.0
    var maxDate: TimeInterval = 0.0
    var timeInterval: TimeInterval = 0.0
    var pixelsPerSecond: Double = 0.0
    var pixelsPerValue: Double = 0.0
    var yInterval: Double = 0.0
    
    private var leftLimit: CGFloat = 0.0
    private var rightLimit: CGFloat = 0.0
    var sliderWidth: CGFloat {
        return min(bounds.width * sliderRelativeWidth, bounds.width - chartInsets.left - chartInsets.right)
    }
    
    var sliderRelativeWidth: CGFloat = 0.0 {
        didSet {
            updateLimits()
            updateSliderPosition()
        }
    }
    var currentRelativeOffset: CGFloat = 0.0 {
        didSet {
            updateLimits()
            updateSliderPosition()
        }
    }
    var onRelativeOffsetChanged: ((CGFloat) -> Void)?
    
    required init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .background1
        isOpaque = false
        
        setupSlider()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSliderPosition()
        updateLimits()
    }
    
    private func updateSliderPosition() {
        let realWidth = bounds.width - chartInsets.right - chartInsets.left
        slider.frame = CGRect(
            x: min(realWidth * currentRelativeOffset + chartInsets.left, rightLimit),
            y: yMargin,
            width: sliderWidth,
            height: bounds.height - yMargin * 2.0
        )
    }
    
    private func updateLimits() {
        leftLimit = chartInsets.left
        rightLimit = bounds.width - chartInsets.right - sliderWidth
    }
    
    private func setupSlider() {
        addSubview(slider)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawGlucoseChart()
    }
    
    private var tapCenterXOffset: CGFloat?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard (1.0 - sliderRelativeWidth) > .ulpOfOne else { return }
        guard let location = touches.first?.location(in: self) else { return }
        if slider.frame.contains(location) {
            tapCenterXOffset = location.x - slider.frame.origin.x - slider.bounds.width / 2.0
        } else {
            slider.center.x = location.x
            tapCenterXOffset = 0.0
        }
        
        changeRelativeOffset(for: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard (1.0 - sliderRelativeWidth) > .ulpOfOne else { return }
        changeRelativeOffset(for: touches)
    }
    
    private func changeRelativeOffset(for touches: Set<UITouch>) {
        guard let location = touches.first?.location(in: self) else { return }
        guard let offset = tapCenterXOffset else { return }
        var targetX = location.x - offset - slider.bounds.width / 2.0
        if targetX < leftLimit {
            targetX = leftLimit
        } else if targetX > rightLimit {
            targetX = rightLimit
        }
        
        currentRelativeOffset = (-chartInsets.left + targetX) / (bounds.width - chartInsets.right - chartInsets.left)
        onRelativeOffsetChanged?(currentRelativeOffset)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {}
}

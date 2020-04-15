//
//  ChartScrollView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class ChartScrollView: UIView, GlucoseChartProvider {
    private let chartInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
    var insets: UIEdgeInsets {
        return chartInsets
    }
    
    let circleSide: CGFloat = 4.0
    private let yMargin: CGFloat = 1.0
    
    private lazy var slider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.chartGridLineColor.cgColor
        view.isUserInteractionEnabled = true
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sliderPanned(_:)))
        view.addGestureRecognizer(panRecognizer)
        
        return view
    }()
    
    var entries: [GlucoseChartGlucoseEntry] = []
    var dateInterval = DateInterval()
    var yRange: ClosedRange<Double> = 0.0...0.0
    
    private var leftLimit: CGFloat = 0.0
    private var rightLimit: CGFloat = 0.0
    private var sliderWidth: CGFloat {
        return (bounds.width - chartInsets.left - chartInsets.right + 8.0) * sliderRelativeWidth + 4.0
    }
    
    var sliderRelativeWidth: CGFloat = 0.0
    var currentRelativeOffset: CGFloat = 0.0
    var onRelativeOffsetChanged: ((CGFloat) -> Void)?
    
    required init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        isOpaque = false
        
        setupSlider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSliderPosition()
        updateLimits()
    }
    
    private func updateSliderPosition() {
        slider.frame = CGRect(
            x: (bounds.width - chartInsets.right - chartInsets.left) * currentRelativeOffset + chartInsets.left - 4.0,
            y: yMargin,
            width: sliderWidth,
            height: bounds.height - yMargin * 2.0
        )
    }
    
    private func updateLimits() {
        leftLimit = chartInsets.left
        rightLimit = bounds.width - chartInsets.right - sliderWidth + 4.0
    }
    
    private func setupSlider() {
        addSubview(slider)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawGlucoseChart()
    }
    
    private var tapCenterXOffset: CGFloat?
    
    @objc private func sliderPanned(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            tapCenterXOffset = sender.location(in: slider).x
            
        case .changed:
            guard let offset = tapCenterXOffset else { return }
            let location = sender.location(in: self)
            let targetX = location.x - offset - slider.bounds.width / 2.0
            if targetX >= leftLimit && targetX <= rightLimit {
                slider.frame.origin.x = targetX
                currentRelativeOffset = slider.frame.origin.x / (bounds.width - chartInsets.right - chartInsets.left)
            }
            
        default: break
        }
    }
}

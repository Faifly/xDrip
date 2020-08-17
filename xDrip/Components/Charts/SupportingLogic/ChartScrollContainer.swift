//
//  GlucoseChartScrollContainer.swift
//  xDrip
//
//  Created by Artem Kalmykov on 18.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class ChartScrollContainer: UIView {
    var onSelectionChanged: ((CGFloat) -> Void)?
    var shouldHandleTouches = true
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.isUserInteractionEnabled = false
        return scrollView
    }()
    
    private let selectionIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .chartSelectionLine
        view.isHidden = true
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        addSubview(scrollView)
        scrollView.bindToSuperview()
        addSubview(selectionIndicator)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
    
    func hideDetailView() {
        selectionIndicator.isHidden = true
    }
    
    private func updateFrame(forTouchX touchX: CGFloat) {
        let finalX: CGFloat
        if touchX < 0.0 {
            finalX = 0.0
        } else if touchX > bounds.width {
            finalX = bounds.width
        } else {
            finalX = touchX
        }
        
        let relative = finalX / bounds.width
        onSelectionChanged?(relative)
        
        selectionIndicator.frame = CGRect(
            x: finalX - 1.0,
            y: 0.0,
            width: 2.0,
            height: bounds.size.height
        )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard shouldHandleTouches else { return }
        guard let location = touches.first?.location(in: self) else { return }
        updateFrame(forTouchX: location.x)
        selectionIndicator.isHidden = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard shouldHandleTouches else { return }
        guard let location = touches.first?.location(in: self) else { return }
        updateFrame(forTouchX: location.x)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}

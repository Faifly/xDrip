//
//  TimeFrameSelectionView.swift
//  xDrip
//
//  Created by Ivan Skoryk on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class TimeFrameSelectionView: UIView {
    
    typealias SegmentChangeCallback = (Int) -> ()
    
    private let backgroundViewCornerRadius: CGFloat = 9.0
    private let selectedSegmentViewCornerRadius: CGFloat = 7.0
    
    
    private var selectedSegmentBackgroundView = UIView()
    private var selectedSegmentViewWidthConstraint: NSLayoutConstraint?
    private var selectedSegmentViewLeadingConstraint: NSLayoutConstraint?
    
    private var separators: [UIView] = []
    private var stackView = UIStackView()
    private var selectedSegment = 0
    
    private var hiddenSeparators: [UIView?] = []
    
    private var singleSegmentWidth: CGFloat = 0.0
    
    private var buttons: [String] = []
    
    var segmentChangedHandler: SegmentChangeCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override var bounds: CGRect {
        didSet {
            self.singleSegmentWidth = (self.frame.width - CGFloat(4 * buttons.count)) / CGFloat(buttons.count)
            self.selectedSegmentViewWidthConstraint?.constant = singleSegmentWidth
            
            self.setupSeparators()
        }
    }
    
    private func setupUI() {
        self.layer.cornerRadius = backgroundViewCornerRadius
        self.backgroundColor = UIColor.timeFrameSegmentBackgroundColor
        
        self.setupSelectedSegmentView()
    }
    
    func config(with buttons: [String]) {
        self.buttons = buttons
        
        self.setupSeparators()
        
        self.bringSubviewToFront(selectedSegmentBackgroundView)
        
        self.setupStackView()
        
        self.setupButtons()
    }
    
    private func setupButtons() {
        for (i, button) in self.buttons.enumerated() {
            let font = UIFont.systemFont(ofSize: 16.0, weight: selectedSegment == i ? .medium : .regular)
            
            let btn = createButton(with: button, font: font, tag: i)
            btn.addTarget(self, action: #selector(onSegmentButtonTap(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(btn)
        }
    }
    
    private func setupStackView() {
        if stackView.superview != nil {
            stackView.removeFromSuperview()
        }
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private func setupSeparators() {
        separators.forEach { (view) in
            view.removeFromSuperview()
        }
        
        separators = []
        hiddenSeparators = []
        
        let width = self.frame.width / CGFloat(self.buttons.count)
        for i in 0 ..< self.buttons.count - 1 {
            let separator = UIView()
            separator.backgroundColor = UIColor.timeFrameSegmentSeparatorColor
            
            if selectedSegment == i {
                separator.alpha = 0.0
                hiddenSeparators.append(separator)
            } else {
                separator.alpha = 0.3
            }
            
            separator.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(separator)
            
            let widthConstraint = CGFloat(i + 1) * width
            
            separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: widthConstraint - 1).isActive = true
            separator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            separator.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 12.0).isActive = true
            
            separators.append(separator)
        }
    }
    
    private func setupSelectedSegmentView() {
        if selectedSegmentBackgroundView.superview != nil {
            selectedSegmentBackgroundView.removeFromSuperview()
        }
        
        selectedSegmentBackgroundView = UIView()
        selectedSegmentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(selectedSegmentBackgroundView)
        
        selectedSegmentBackgroundView.backgroundColor = UIColor.timeFrameSegmentSelectedColor
        selectedSegmentBackgroundView.layer.cornerRadius = selectedSegmentViewCornerRadius
        
        selectedSegmentBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
        selectedSegmentBackgroundView.layer.shadowRadius = 3
        selectedSegmentBackgroundView.layer.shadowOpacity = 0.12
        selectedSegmentBackgroundView.layer.shadowColor = UIColor.black.cgColor
        
        selectedSegmentViewLeadingConstraint = selectedSegmentBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2.0)
        selectedSegmentViewLeadingConstraint?.isActive = true
        
        selectedSegmentBackgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.0).isActive = true
        selectedSegmentBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2.0).isActive = true
        
        selectedSegmentViewWidthConstraint = selectedSegmentBackgroundView.widthAnchor.constraint(equalToConstant: self.frame.width - 4)
        selectedSegmentViewWidthConstraint?.isActive = true
    }
    
    private func createButton(with title: String, font: UIFont, tag: Int) -> UIButton {
        let button = UIButton()
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.timeFrameSegmentLabelColor, for: .normal)
        button.titleLabel?.textAlignment = .center
        
        button.titleLabel?.font = font
        
        button.tag = tag
        
        return button
    }
    
    private func selectSegment(index: Int) {
        guard stackView.arrangedSubviews.count > 1,
            let prevButton = stackView.arrangedSubviews[selectedSegment] as? UIButton,
            let selectedButton = stackView.arrangedSubviews[index] as? UIButton  else {
            return
        }
        
        selectedSegment = index
        
        let newLeadingConstraingConstant = 2 + CGFloat(index) * (singleSegmentWidth + 4)
        self.selectedSegmentViewLeadingConstraint?.constant = newLeadingConstraingConstant
        
        var firstSeparator: UIView? = nil
        var secondSeparator: UIView? = nil
        
        if index == 0 {
            firstSeparator = separators[0]
        } else if index == separators.count {
            secondSeparator = separators[separators.count - 1]
        } else {
            firstSeparator = separators[index - 1]
            secondSeparator = separators[index]
        }
        
        hiddenSeparators.removeAll(where: { $0 == firstSeparator || $0 == secondSeparator })
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            
            prevButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
            selectedButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
            
            self.hiddenSeparators.forEach { (view) in
                view?.alpha = 0.3
            }
            
            firstSeparator?.alpha = 0
            secondSeparator?.alpha = 0
            
            self.hiddenSeparators = [firstSeparator, secondSeparator]
        }
    }
    
    @objc
    private func onSegmentButtonTap(_ button: UIButton) {
        guard selectedSegment != button.tag else {
            return
        }
        
        selectSegment(index: button.tag)
        segmentChangedHandler?(button.tag)
    }
}

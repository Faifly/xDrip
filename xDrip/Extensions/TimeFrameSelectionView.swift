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
    
    private let separatorWidthConstraintConstant: CGFloat = 1.0
    private let separatorHeightConstraintConstant: CGFloat = 12.0
    
    private let labelRegularFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    private let labelMediumFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    
    private var selectedSegmentBackgroundView = UIView()
    private var selectedSegmentViewWidthConstraint: NSLayoutConstraint? = nil
    private var selectedSegmentViewLeadingConstraint: NSLayoutConstraint? = nil
    
    private var separators: [UIView] = []
    private var stackView = UIStackView()
    private var selectedSegment = 0
    
    private var hiddenSeparators: [UIView] = []
    
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
            self.bringSubviewToFront(selectedSegmentBackgroundView)
            self.bringSubviewToFront(stackView)
        }
    }
    
    private func setupUI() {
        self.layer.cornerRadius = backgroundViewCornerRadius
        self.backgroundColor = UIColor.timeFrameSegmentBackgroundColor
    }
    
    func config(with buttons: [String]) {
        self.buttons = buttons
        
        self.setupSeparators()
        self.setupSelectedSegmentView()
        self.setupStackView()
        self.setupButtons()
    }
    
    private func setupButtons() {
        for (i, button) in self.buttons.enumerated() {
            let font = selectedSegment == i ? labelMediumFont : labelRegularFont
            
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
            separator.widthAnchor.constraint(equalToConstant: separatorWidthConstraintConstant).isActive = true
            separator.heightAnchor.constraint(equalToConstant: separatorHeightConstraintConstant).isActive = true
            
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
        
        let count = buttons.count == 0 ? 1 : buttons.count
        self.singleSegmentWidth = (self.frame.width - CGFloat(4 * count)) / CGFloat(count)
        selectedSegmentViewWidthConstraint = selectedSegmentBackgroundView.widthAnchor.constraint(equalToConstant: singleSegmentWidth)
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
        
        let newLeadingConstraingConstant = 2.0 + CGFloat(index) * (singleSegmentWidth + 4.0)
        self.selectedSegmentViewLeadingConstraint?.constant = newLeadingConstraingConstant
        
        var separatorsToHide: [UIView] = []
        
        if index == 0 {
            separatorsToHide.append(separators[0])
        } else if index == separators.count {
            separatorsToHide.append(separators[separators.count - 1])
        } else {
            separatorsToHide.append(separators[index - 1])
            separatorsToHide.append(separators[index])
        }
        
        hiddenSeparators = Array(Set(hiddenSeparators).subtracting(separatorsToHide))
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            
            prevButton.titleLabel?.font = self.labelRegularFont
            selectedButton.titleLabel?.font = self.labelMediumFont
            
            self.hiddenSeparators.forEach { (view) in
                view.alpha = 0.3
            }
            
            separatorsToHide.forEach { (view) in
                view.alpha = 0.0
            }
            
            self.hiddenSeparators = separatorsToHide
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

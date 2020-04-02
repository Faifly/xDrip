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
    private let hiddenSeparatorAlpha: CGFloat = 0.0
    private let showedSeparatorAlpha: CGFloat = 0.3
    
    private let selectedSegmentViewConstraintsToSuperviewConstant: CGFloat = 2.0
    
    private let labelDeselectedFont = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    private let labelSelectedFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    
    private let animationDuration = 0.3
    
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
            let count: CGFloat = buttons.count == 0 ? 1.0 : CGFloat(buttons.count)
            singleSegmentWidth = ((frame.width - (2.0 * selectedSegmentViewConstraintsToSuperviewConstant * count)) / count)
            selectedSegmentViewWidthConstraint?.constant = singleSegmentWidth
            
            setupSeparators()
            bringSubviewToFront(selectedSegmentBackgroundView)
            bringSubviewToFront(stackView)
        }
    }
    
    private func setupUI() {
        layer.cornerRadius = backgroundViewCornerRadius
        backgroundColor = .timeFrameSegmentBackgroundColor
    }
    
    func config(with buttons: [String]) {
        self.buttons = buttons
        
        setupSeparators()
        setupSelectedSegmentView()
        setupStackView()
        setupButtons()
        selectSegment(index: 0)
    }
    
    private func setupButtons() {
        for (i, button) in self.buttons.enumerated() {
            let font = selectedSegment == i ? labelSelectedFont : labelDeselectedFont
            
            let btn = createButton(with: button,
                                   font: font,
                                   tag: i)
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
        
        addSubview(stackView)
        
        stackView.bindToSuperview()
    }
    
    private func setupSeparators() {
        separators.forEach { (view) in
            view.removeFromSuperview()
        }
        
        separators = []
        hiddenSeparators = []
        
        guard buttons.count > 1 else {
            return
        }
        
        let width = self.frame.width / CGFloat(buttons.count)
        for i in 0 ..< buttons.count - 1 {
            let separator = UIView()
            separator.backgroundColor = .timeFrameSegmentSeparatorColor
            
            if selectedSegment == i {
                separator.alpha = hiddenSeparatorAlpha
                hiddenSeparators.append(separator)
            } else {
                separator.alpha = showedSeparatorAlpha
            }
            
            separator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(separator)
            
            let widthConstraint = CGFloat(i + 1) * width
            
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: widthConstraint - 1).isActive = true
            separator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
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
        
        addSubview(selectedSegmentBackgroundView)
        
        selectedSegmentBackgroundView.backgroundColor = .timeFrameSegmentSelectedColor
        selectedSegmentBackgroundView.layer.cornerRadius = selectedSegmentViewCornerRadius
        
        selectedSegmentBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
        selectedSegmentBackgroundView.layer.shadowRadius = 3
        selectedSegmentBackgroundView.layer.shadowOpacity = 0.12
        selectedSegmentBackgroundView.layer.shadowColor = UIColor.black.cgColor
        
        selectedSegmentViewLeadingConstraint = selectedSegmentBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: selectedSegmentViewConstraintsToSuperviewConstant)
        selectedSegmentViewLeadingConstraint?.isActive = true
        
        selectedSegmentBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: selectedSegmentViewConstraintsToSuperviewConstant).isActive = true
        selectedSegmentBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -selectedSegmentViewConstraintsToSuperviewConstant).isActive = true
        
        let count: CGFloat = buttons.count == 0 ? 1.0 : CGFloat(buttons.count)
        singleSegmentWidth = ((frame.width - (2.0 * selectedSegmentViewConstraintsToSuperviewConstant * count)) / count)
        selectedSegmentViewWidthConstraint = selectedSegmentBackgroundView.widthAnchor.constraint(equalToConstant: singleSegmentWidth)
        selectedSegmentViewWidthConstraint?.isActive = true
    }
    
    private func createButton(with title: String, font: UIFont, tag: Int) -> UIButton {
        let button = UIButton()
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.timeFrameSegmentLabelColor, for: .normal)
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
        
        let newLeadingConstraingConstant = selectedSegmentViewConstraintsToSuperviewConstant + CGFloat(index) * (singleSegmentWidth + 2 * selectedSegmentViewConstraintsToSuperviewConstant)
        selectedSegmentViewLeadingConstraint?.constant = newLeadingConstraingConstant
        
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
        
        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
            
            prevButton.titleLabel?.font = self.labelDeselectedFont
            selectedButton.titleLabel?.font = self.labelSelectedFont
            
            self.hiddenSeparators.forEach { (view) in
                view.alpha = self.showedSeparatorAlpha
            }
            
            separatorsToHide.forEach { (view) in
                view.alpha = self.hiddenSeparatorAlpha
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

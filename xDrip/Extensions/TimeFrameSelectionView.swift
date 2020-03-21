//
//  TimeFrameSelectionView.swift
//  xDrip
//
//  Created by Ivan Skoryk on 20.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol TimeFrameSelectionDelegate: class {
    func segmentDidChange(index: Int)
}

class TimeFrameSelectionView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var selectedSegmentBackgroundView: UIView!
    @IBOutlet weak var selectedSegmentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedSegmentViewLeadingConstraint: NSLayoutConstraint!
    
    weak var delegate: TimeFrameSelectionDelegate?
    
    private var separators: [UIView] = []
    private var stackView = UIStackView()
    private var selectedSegment = 0
    
    private var hiddenSeparators: [UIView?] = []
    
    private var singleSegmentWidth: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TimeFrameSelectionView", owner: self, options: nil)

        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 9
        self.selectedSegmentBackgroundView.layer.cornerRadius = 7
        
        self.selectedSegmentBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.selectedSegmentBackgroundView.layer.shadowRadius = 3
        self.selectedSegmentBackgroundView.layer.shadowOpacity = 0.12
        self.selectedSegmentBackgroundView.layer.shadowColor = UIColor.black.cgColor
    }
    
    func config(with buttons: [String]) {
        if stackView.superview != nil {
            stackView.removeFromSuperview()
        }
        
        separators.forEach { (view) in
            view.removeFromSuperview()
        }
        
        self.singleSegmentWidth = (self.contentView.frame.width - CGFloat(4 * buttons.count)) / CGFloat(buttons.count)
        self.selectedSegmentViewWidthConstraint.constant = singleSegmentWidth
        
        let width = self.contentView.frame.width / CGFloat(buttons.count)
        for i in 0 ..< buttons.count - 1  {
            let separator = UIView()
            separator.backgroundColor = UIColor(named: "timeFrameSegmentSeparatorColor")
            separator.alpha = selectedSegment == i ? 0.0 : 0.3
            
            separator.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(separator)
            
            let widthConstraint = CGFloat(i + 1) * width
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthConstraint - 1).isActive = true
            separator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            separator.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 12.0).isActive = true
            
            separators.append(separator)
        }
        
        contentView.bringSubviewToFront(selectedSegmentBackgroundView)
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        for (i, button) in buttons.enumerated() {
            let btn = UIButton()
            
            btn.setTitle(button, for: .normal)
            btn.setTitleColor(UIColor(named: "timeFrameSegmentLabelColor"), for: .normal)
            btn.titleLabel?.textAlignment = .center
            
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: selectedSegment == i ? .medium : .regular)
            
            btn.tag = i
            btn.addTarget(self, action: #selector(onSegmentButtonTap(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(btn)
        }
    }
    
    private func selectSegment(index: Int) {
        guard stackView.arrangedSubviews.count > 1 else {
            return
        }
        
        let prevButton = stackView.arrangedSubviews[selectedSegment] as! UIButton
        let selectedButton = stackView.arrangedSubviews[index] as! UIButton
        
        selectedSegment = index
        
        let newLeadingConstraingConstant = 2 + CGFloat(index) * (singleSegmentWidth + 4)
        self.selectedSegmentViewLeadingConstraint.constant = newLeadingConstraingConstant
        
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
            self.contentView.layoutIfNeeded()
            
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
        delegate?.segmentDidChange(index: button.tag)
    }
}

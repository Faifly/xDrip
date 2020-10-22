//
//  ChartEntryDetailView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 18.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class ChartEntryDetailView: UIView {
    private let labelInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    
    let containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1000.0, height: 58.0))
        view.backgroundColor = .chartSelectionLine
        view.layer.cornerRadius = 5.0
        view.translatesAutoresizingMaskIntoConstraints = true
        view.isHidden = true
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.numberOfLines = 2
        return label
    }()
    
    private var relativeOffset: CGFloat = 0.0
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isOpaque = false
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(label)
        label.bindToSuperview(inset: labelInsets)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not permitted")
    }
    
    func setRelativeOffset(_ offset: CGFloat) {
        relativeOffset = offset
        updateFrame()
    }
    
    func set(value: Double, unit: String, date: Date) {
        setText(
            topLeft: String(format: "%0.1f", value),
            topRight: unit,
            bottom: DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
        )
    }
    
    func setText(topLeft: String, topRight: String, bottom: String) {
        let finalString = NSMutableAttributedString()
        
        let valueSubstring = NSAttributedString(
            string: topLeft,
            attributes: [
                .font: UIFont.systemFont(ofSize: 26.0, weight: .medium),
                .foregroundColor: UIColor.highEmphasisText
            ]
        )
        finalString.append(valueSubstring)
        
        let unitSubstring = NSAttributedString(
            string: " \(topRight)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                .foregroundColor: UIColor.mediumEmphasisText
            ]
        )
        finalString.append(unitSubstring)
        
        let dateSubstring = NSAttributedString(
            string: bottom,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                .foregroundColor: UIColor.mediumEmphasisText
            ]
        )
        finalString.append(dateSubstring)
        
        setAttributtedText(finalString)
    }
    
    func setAttributtedText(_ text: NSAttributedString) {
        label.attributedText = text
        updateFrame()
    }
    
    func setHidden(_ hidden: Bool) {
        containerView.isHidden = hidden
    }
    
    private func updateFrame() {
        let textSize = label.sizeThatFits(CGSize(width: 1000.0, height: 58.0))
        var desiredCenter = bounds.width * relativeOffset
        if desiredCenter - textSize.width / 2.0 < 0.0 {
            desiredCenter = textSize.width / 2.0
        } else if desiredCenter + textSize.width / 2.0 > bounds.width {
            desiredCenter = bounds.width - textSize.width / 2.0
        }
        
        containerView.frame = CGRect(
            x: desiredCenter - textSize.width / 2.0,
            y: 0.0,
            width: textSize.width + labelInsets.left + labelInsets.right,
            height: 58.0
        )
    }
}

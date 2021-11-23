//
//  ChartEntryDetailView.swift
//  xDrip
//
//  Created by Artem Kalmykov on 18.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class ChartEntryDetailView: UIView {
    private let labelInsets = UIEdgeInsets(top: min(UIScreen.main.bounds.width * 0.01, 5.0),
                                           left: min(UIScreen.main.bounds.width * 0.02, 5.0),
                                           bottom: min(UIScreen.main.bounds.width * 0.01, 5.0),
                                           right: min(UIScreen.main.bounds.width * 0.02, 5.0))
    
    var leftPadding = 0.0
    var rightPadding = 0.0
    
    let containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 1000.0, height: 58.0))
        view.backgroundColor = .chartDetailsBackground
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
                .font: UIFont.systemFont(ofSize: min(UIScreen.main.bounds.width * 0.04, 26.0), weight: .medium),
                .foregroundColor: UIColor.highEmphasisText
            ]
        )
        finalString.append(valueSubstring)
        
        let unitSubstring = NSAttributedString(
            string: " \(topRight)\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: min(UIScreen.main.bounds.width * 0.03, 14.0), weight: .medium),
                .foregroundColor: UIColor.mediumEmphasisText
            ]
        )
        finalString.append(unitSubstring)
        
        let dateSubstring = NSAttributedString(
            string: bottom,
            attributes: [
                .font: UIFont.systemFont(ofSize: min(UIScreen.main.bounds.width * 0.03, 14.0), weight: .medium),
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
        if desiredCenter - textSize.width / 2.0 < 0.0 + leftPadding {
            desiredCenter = textSize.width / 2.0 + leftPadding
        } else if desiredCenter + textSize.width / 2.0 > bounds.width - rightPadding {
            desiredCenter = bounds.width - textSize.width / 2.0 - rightPadding
        }
        
        containerView.frame = CGRect(
            x: desiredCenter - textSize.width / 2.0,
            y: 0.0,
            width: textSize.width + labelInsets.left + labelInsets.right,
            height: min(UIScreen.main.bounds.width * 0.12, 58.0)
        )
    }
}

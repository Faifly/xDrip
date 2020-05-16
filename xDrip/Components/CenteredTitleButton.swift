//
//  CenteredTitleButton.swift
//  xDrip
//
//  Created by Ivan Skoryk on 19.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class CenteredTitleButton: UIButton {    
    let padding: CGFloat = 5.0
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)

        return CGRect(
            x: 0,
            y: contentRect.height - rect.height,
            width: contentRect.width,
            height: rect.height
        )
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)

        return CGRect(
            x: contentRect.width / 2.0 - rect.width / 2.0,
            y: 0,
            width: rect.width,
            height: rect.height
        )
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize

        if let image = imageView?.image {
            var labelHeight: CGFloat = 0.0
            
            let contentSize = CGSize(
                width: self.contentRect(forBounds: self.bounds).width,
                height: CGFloat.greatestFiniteMagnitude
            )

            if let size = titleLabel?.sizeThatFits(contentSize) {
                labelHeight = size.height
            }

            return CGSize(
                width: max(titleLabel?.frame.width ?? 0.0, image.size.width),
                height: image.size.height + labelHeight + padding
            )
        }

        return size
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        centerTitleLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }

    private func centerTitleLabel() {
        self.titleLabel?.textAlignment = .center
    }
}

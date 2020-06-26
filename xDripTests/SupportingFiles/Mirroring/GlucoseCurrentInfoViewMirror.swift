//
//  GlucoseCurrentInfoViewMirror.swift
//  xDripTests
//
//  Created by Dmitry on 6/26/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
@testable import xDrip

final class GlucoseCurrentInfoViewMirror: MirrorObject {
    init(view: GlucoseCurrentInfoView) {
        super.init(reflecting: view)
    }
    
    var glucoseIntValueLabel: UILabel? {
        return extract()
    }
    var glucoseDecimalValueLablel: UILabel? {
        return extract()
    }
    var slopeArrowLabel: UILabel? {
        return extract()
    }
    var lastScanTitleLabel: UILabel? {
        return extract()
    }
    var lastScanValueLabel: UILabel? {
        return extract()
    }
    var difTitleLabel: UILabel? {
        return extract()
    }
    var difValueLabel: UILabel? {
        return extract()
    }
}

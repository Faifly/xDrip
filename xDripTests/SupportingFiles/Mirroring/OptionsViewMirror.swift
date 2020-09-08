//
//  OptionsViewMirror.swift
//  xDripTests
//
//  Created by Dmitry on 07.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
@testable import xDrip

final class OptionsViewMirror: MirrorObject {
    init(view: OptionsView) {
        super.init(reflecting: view)
    }
    
    var contentView: UIView? {
        return extract()
    }
    
    var allTrainingsTilteLabel: UILabel? {
        return extract()
    }
    var allBasalsTitleLabel: UILabel? {
        return extract()
    }
    var allTrainingsContentView: UIView? {
        return extract()
    }
    var allBasalsContentView: UIView? {
        return extract()
    }
}

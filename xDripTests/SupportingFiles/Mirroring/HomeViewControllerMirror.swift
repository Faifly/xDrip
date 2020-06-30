//
//  HomeViewControllerMirror.swift
//  xDripTests
//
//  Created by Dmitry on 6/26/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
@testable import xDrip

final class HomeViewControllerMirror: MirrorObject {
    init(viewController: HomeViewController) {
        super.init(reflecting: viewController)
    }
    
    var glucoseCurrentInfoView: GlucoseCurrentInfoView? {
        return extract()
    }
}

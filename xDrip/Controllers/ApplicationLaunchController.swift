//
//  ApplicationLaunchController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 05.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
#if !targetEnvironment(macCatalyst)
import FirebaseCore
#endif

final class ApplicationLaunchController {
    static func runAppLaunchSequence() {
        #if !targetEnvironment(macCatalyst)
        FirebaseApp.configure()
        #endif
    }
}

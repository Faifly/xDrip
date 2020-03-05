//
//  ApplicationLaunchController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 05.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseCrashlytics

final class ApplicationLaunchController {
    static func runAppLaunchSequence() {
        FirebaseApp.configure()
    }
}

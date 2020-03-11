//
//  UIStoryboard+Content.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

extension UIStoryboard {
    enum Storyboard: String {
        case root = "Root"
        case home = "Home"
        case stats = "Stats"
        case history = "History"
        case settings = "Settings"
    }
    
    convenience init(board: Storyboard) {
        self.init(name: board.rawValue, bundle: nil)
    }
}

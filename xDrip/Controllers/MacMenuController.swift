//
//  MacMenuController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 06.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

#if targetEnvironment(macCatalyst)
final class MacMenuController {
    static func buildMenu(_ builder: UIMenuBuilder) {
        let developElements = [
            UIAction(title: "Show debug log", handler: { _ in
                DebugController.shared.showLogWindow()
            }),
            UIAction(title: "Purge database & exit", handler: { _ in
                DebugController.shared.purgeDatabase()
            })
        ] as [UIMenuElement]
        
        let developMenu = UIMenu(
            title: "Developer",
            image: nil,
            identifier: UIMenu.Identifier(rawValue: "developer"),
            options: [],
            children: developElements
        )
        
        builder.insertSibling(developMenu, beforeMenu: .help)
    }
}
#endif

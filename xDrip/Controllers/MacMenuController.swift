//
//  MacMenuController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 06.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

#if targetEnvironment(macCatalyst)
enum MacMenuController {
    static func buildMenu(_ builder: UIMenuBuilder) {
        let injectChildren = createInjectChildrenMenu()
        
        let injectMenu = UIMenu(
            title: "Inject mocked CGM service",
            image: nil,
            identifier: nil,
            options: [],
            children: injectChildren
        )
        
        let developElements = [
            UIAction(
                title: "Show debug log",
                handler: { _ in
                    DebugController.shared.showLogWindow()
                }
            ),
            UIAction(
                title: "Purge database & exit",
                handler: { _ in
                    DebugController.shared.purgeDatabase()
                }
            ),
            injectMenu
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
    
    private static func createInjectChildrenMenu() -> [UIMenuElement] {
        return [
            UIAction(
                title: "Dexcom G6 simulation",
                handler: { _ in
                    self.injectMockedCGM(with: .dexcomG6Immitation)
                }
            ),
            UIAction(
                title: "Quick updates",
                handler: { _ in
                    self.injectMockedCGM(with: .quickUpdate)
                }
            ),
            UIAction(
                title: "Fast rise",
                handler: { _ in
                    self.injectMockedCGM(with: .fastRise)
                }
            ),
            UIAction(
                title: "Fast fall",
                handler: { _ in
                    self.injectMockedCGM(with: .fastFall)
                }
            ),
            UIAction(
                title: "Abnormal",
                handler: { _ in
                    self.injectMockedCGM(with: .abnormal)
                }
            ),
            UIAction(
                title: "Faily",
                handler: { _ in
                    self.injectMockedCGM(with: .faily)
                }
            )
        ] as [UIMenuElement]
    }
    
    private static func injectMockedCGM(with mode: MockedBluetoothServiceConfiguration.Predefined) {
        MockedBluetoothServiceConfiguration.current = mode.configuration
        let service = MockedBluetoothService(delegate: CGMController.shared)
        CGMController.shared.injectBluetoothService(service)
    }
}
#endif

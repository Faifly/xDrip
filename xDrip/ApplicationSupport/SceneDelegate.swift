//
//  SceneDelegate.swift
//  xDrip
//
//  Created by Artem Kalmykov on 23.02.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        if session.configuration.name == DebugController.debugLogWindowID {
            windowScene.title = "Debug Log"
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = DebugLogViewController()
            window.makeKeyAndVisible()
            self.window = window
        } else if let window = UIApplication.shared.delegate?.window {
            self.window = window
            window?.windowScene = windowScene
        }
    }
}

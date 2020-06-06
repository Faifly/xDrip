//
//  UIApplication+TopViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

public extension UIApplication {
    class func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        let searchFromVC = controller == nil ? rootVC : controller
        
        if let navigationController = searchFromVC as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = searchFromVC as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = searchFromVC?.presentedViewController {
            return topViewController(controller: presented)
        }
        return searchFromVC
    }
}

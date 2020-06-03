//
//  AlertPresenter.swift
//  xDrip
//
//  Created by Artem Kalmykov on 30.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

private class WeakWatcher {
    private static var key: UInt8 = 0
    
    private var onDeinit: () -> Void

    init(onDeinit: @escaping () -> Void) {
        self.onDeinit = onDeinit
    }

    static func watch(_ obj: Any, onDeinit: @escaping () -> Void) {
        watch(obj, key: &WeakWatcher.key, onDeinit: onDeinit)
    }

    static func watch(_ obj: Any, key: UnsafeRawPointer, onDeinit: @escaping () -> Void) {
        objc_setAssociatedObject(
            obj,
            key,
            WeakWatcher(onDeinit: onDeinit),
            objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
        )
    }

    deinit {
        self.onDeinit()
    }
}

final class AlertPresenter {
    static let shared = AlertPresenter()
    private init() {}
    
    private var alertQueue: [UIAlertController] = []
    private weak var currentAlert: UIAlertController?
    
    func presentAlert(_ alert: UIAlertController) {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return }
        if alertQueue.isEmpty && currentAlert == nil {
            presentNextAlert(alert)
        } else {
            alertQueue.append(alert)
        }
    }
    
    private func presentNextAlert(_ alert: UIAlertController) {
        currentAlert = alert
        WeakWatcher.watch(alert) { [weak self] in
            guard let self = self else { return }
            if !self.alertQueue.isEmpty {
                self.presentNextAlert(self.alertQueue.remove(at: 0))
            }
        }
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}

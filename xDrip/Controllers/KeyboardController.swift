//
//  KeyboardController.swift
//  xDrip
//
//  Created by Dmitry on 25.06.2021.
//  Copyright © 2021 Faifly. All rights reserved.
//

import Foundation
import UIKit

final class KeyboardController {
    static let shared = KeyboardController()
    
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    typealias KeyboardCallback = (_ willShow: Bool, _ height: CGFloat?) -> Void
    
    private var listeners: [AnyHashable: KeyboardCallback] = [:]
    
    func subscribe(listener: AnyHashable, callback: @escaping KeyboardCallback) {
        listeners[listener] = callback
    }
    
    func unsubscribe(listener: AnyHashable) {
        listeners.removeValue(forKey: listener)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let notificationValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        let keyboardHeight = notificationValue?.cgRectValue.height
        listeners.values.forEach { $0(true, keyboardHeight) }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let notificationValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        let keyboardHeight = notificationValue?.cgRectValue.height
        listeners.values.forEach { $0(false, keyboardHeight) }
    }
}

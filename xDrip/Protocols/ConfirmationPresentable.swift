//
//  ConfirmationPresentable.swift
//  xDrip
//
//  Created by Artem Kalmykov on 29.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

protocol ConfirmationPresentable {
    associatedtype T: UIViewController
    var viewController: T? { get }
    
    func presentConfirmation(prefix: String, completion: @escaping (Bool) -> Void)
    func presentConfirmation(title: String?,
                             message: String?,
                             confirmButton: String?,
                             cancelButton: String?,
                             completion: @escaping (Bool) -> Void)
}

extension ConfirmationPresentable {
    func presentConfirmation(prefix: String, completion: @escaping (Bool) -> Void) {
        presentConfirmation(
            title: "\(prefix)_alert_title".localized,
            message: "\(prefix)_alert_message".localized,
            confirmButton: "\(prefix)_alert_confirm_button".localized,
            cancelButton: "\(prefix)_alert_cancel_button".localized,
            completion: completion
        )
    }
    
    func presentConfirmation(title: String?,
                             message: String?,
                             confirmButton: String?,
                             cancelButton: String?,
                             completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(
            title: confirmButton,
            style: .destructive
        ) { _ in
            completion(true)
        }
        alert.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(
            title: cancelButton,
            style: .cancel
        ) { _ in
            completion(false)
        }
        alert.addAction(cancelAction)
        
        viewController?.present(alert, animated: true, completion: nil)
    }
}

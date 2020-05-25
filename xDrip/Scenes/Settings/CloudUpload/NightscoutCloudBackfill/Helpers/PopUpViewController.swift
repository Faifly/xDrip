//
//  PopUpViewController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class PopUpViewController: NibViewController {
    @IBOutlet private weak var activityIndicatorContainerView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var okActionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(macCatalyst)
        activityIndicator.style = .medium
        #else
        if #available(iOS 12.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .dark: activityIndicator.style = .white
            default: activityIndicator.style = .gray
            }
        }
        #endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [weak self] in
            self?.presentGlucoseAlert(queuedReadings: 614, queuedTreatments: 0)
        }
    }

    func presentGlucoseAlert(queuedReadings: Int, queuedTreatments: Int) {
        activityIndicatorContainerView.isHidden = true
        
        let message = "Queued \(queuedReadings) glucose readings and \(queuedTreatments) treatments"
        
        #if targetEnvironment(macCatalyst)
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(createOKAction())
        present(alertController, animated: true)
        #else
        let alertController = CustomAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.setTitleImage(UIImage(named: "icon_error")?.withRenderingMode(.alwaysOriginal))
        
        alertController.addAction(createOKAction())
        
        present(alertController, animated: true)
        #endif
    }
    
    private func createOKAction() -> UIAlertAction {
        return UIAlertAction(
            title: "OK",
            style: .cancel,
            handler: { [weak self] _ in
                self?.okActionHandler?()
                self?.dismiss(animated: true, completion: nil)
            }
        )
    }
}

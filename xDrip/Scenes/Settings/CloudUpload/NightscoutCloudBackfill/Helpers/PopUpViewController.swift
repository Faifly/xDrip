//
//  PopUpViewController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 23.05.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

class PopUpViewController: NibViewController {
    @IBOutlet private weak var activityIndicatorContainerView: UIView!
    
    var okActionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [weak self] in
            self?.presentGlucoseAlert(queuedReadings: 614, queuedTreatments: 0)
        }
    }

    func presentGlucoseAlert(queuedReadings: Int, queuedTreatments: Int) {
        activityIndicatorContainerView.isHidden = true
        
        let message = "Queued \(queuedReadings) glucose readings and \(queuedTreatments) treatments"
        
        let alertController = CustomAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.setTitleImage(UIImage(named: "icon_error")?.withRenderingMode(.alwaysOriginal))
        
        alertController.addAction(
            UIAlertAction(
                title: "OK",
                style: .cancel,
                handler: { [weak self] _ in
                    self?.okActionHandler?()
                    self?.dismiss(animated: true, completion: nil)
                }
            )
        )
        
        present(alertController, animated: true)
    }
}

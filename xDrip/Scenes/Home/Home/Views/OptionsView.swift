//
//  OptionsView.swift
//  xDrip
//
//  Created by Dmitry on 04.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

enum Option: Int {
    case allTrainings
    case allBasals
    
    var title: String {
        switch self {
        case .allTrainings:
            return "home_all_trainings".localized
        case .allBasals:
            return "home_all_basals".localized
        }
    }
}

final class OptionsView: NibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var allTrainingsGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var allBasalsGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var allTrainingsTilteLabel: UILabel!
    @IBOutlet private weak var allBasalsTitleLabel: UILabel!
    @IBOutlet private weak var allTrainingsContentView: UIView!
    @IBOutlet private weak var allBasalsContentView: UIView!
    
    var itemSelectionHandler: ((Option) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        allTrainingsTilteLabel.text = Option.allTrainings.title
        allBasalsTitleLabel.text = Option.allBasals.title
        
        allTrainingsGestureRecognizer.addTarget(self, action: #selector (self.onAllTrainingsTapped))
        allBasalsGestureRecognizer.addTarget(self, action: #selector (self.onAllBasalTapped))
    }
    
    @objc func onAllTrainingsTapped(sender: UITapGestureRecognizer) {
        highliteView(allTrainingsContentView)
        itemSelectionHandler?(.allTrainings)
    }
    
    @objc func onAllBasalTapped(sender: UITapGestureRecognizer) {
        highliteView(allBasalsContentView)
        itemSelectionHandler?(.allBasals)
    }
    
    private func highliteView(_ view: UIView) {
        let bgcolor = view.backgroundColor
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.allowUserInteraction, .curveLinear],
                       animations: {
                        view.backgroundColor = .borderColor
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
                view.backgroundColor = bgcolor
            })
        })
    }
}

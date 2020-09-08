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
    @IBOutlet private weak var allTrainingsTilteLabel: UILabel!
    @IBOutlet private weak var allBasalsTitleLabel: UILabel!
    @IBOutlet private weak var allTrainingsContentView: UIView!
    @IBOutlet private weak var allBasalsContentView: UIView!
    
    var itemSelectionHandler: ((Option) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        allTrainingsTilteLabel.text = Option.allTrainings.title
        allBasalsTitleLabel.text = Option.allBasals.title
        
        let allTrainingsGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                   action: #selector(onAllTrainingsTapped(sender:)))
        let allBasalsGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(onAllBasalTapped(sender:)))
        
        allTrainingsContentView.addGestureRecognizer(allTrainingsGestureRecognizer)
        allBasalsContentView.addGestureRecognizer(allBasalsGestureRecognizer)
    }
    
    @objc func onAllTrainingsTapped(sender: UITapGestureRecognizer) {
        itemSelectionHandler?(.allTrainings)
    }
    
    @objc func onAllBasalTapped(sender: UITapGestureRecognizer) {
        itemSelectionHandler?(.allBasals)
    }
}

//
//  DebugLogViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 06.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol DebugLogDisplayLogic: class {
    func displayLoad(viewModel: DebugLog.Load.ViewModel)
    func displayLogs(viewModel: DebugLog.UpdateLog.ViewModel)
}

class DebugLogViewController: NibViewController, DebugLogDisplayLogic {
    var interactor: DebugLogBusinessLogic?
    
    // MARK: Object lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use regular init")
    }
    
    required init() {
        super.init()
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = DebugLogInteractor()
        let presenter = DebugLogPresenter()
        let router = DebugLogRouter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    
    @IBOutlet private weak var textView: UITextView!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = DebugLog.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: DebugLog.Load.ViewModel) {
        
    }
    
    func displayLogs(viewModel: DebugLog.UpdateLog.ViewModel) {
        textView.text = viewModel.logs
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
        
        let offsetY = max(0, textView.contentSize.height - textView.bounds.size.height)
        textView.setContentOffset(CGPoint(x: 0.0, y: offsetY), animated: true)
    }
}
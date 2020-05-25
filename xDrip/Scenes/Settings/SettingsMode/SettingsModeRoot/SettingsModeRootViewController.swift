//
//  SettingsModeRootViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 09.04.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SettingsModeRootDisplayLogic: AnyObject {
    func displayLoad(viewModel: SettingsModeRoot.Load.ViewModel)
}

class SettingsModeRootViewController: NibViewController, SettingsModeRootDisplayLogic {
    var interactor: SettingsModeRootBusinessLogic?
    var router: SettingsModeRootDataPassing?
    
    // MARK: Object lifecycle
    
    @available(*, unavailable)
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
        let interactor = SettingsModeRootInteractor()
        let presenter = SettingsModeRootPresenter()
        let router = SettingsModeRootRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var containerView: UIView!
    
    private var masterViewController: SettingsModeMasterViewController?
    private var followerViewController: SettingsModeFollowerViewController?
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doLoad()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = SettingsModeRoot.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    private func setupUI() {
        title = "settings_mode_settings_title".localized
        
        let masterViewController = SettingsModeMasterViewController()
        let followerViewController = SettingsModeFollowerViewController()
        
        addChild(masterViewController)
        addChild(followerViewController)
        
        self.masterViewController = masterViewController
        self.followerViewController = followerViewController
        
        let titles = UserDeviceMode.allCases.map({ $0.title })
        segmentedControl.removeAllSegments()
        titles.forEach {
            segmentedControl.insertSegment(
                withTitle: $0,
                at: segmentedControl.numberOfSegments,
                animated: false
            )
        }
        
        segmentedControl.selectedSegmentIndex = User.current.settings.deviceMode.rawValue
        onSegmentedControlValueChanged(segmentedControl)
    }
    
    private func setMasterController() {
        guard let view = masterViewController?.view else {
            return
        }
        
        containerView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        view.bindToSuperview()
    }
    
    private func setFollowerController() {
        guard let view = followerViewController?.view else {
            return
        }
        
        containerView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        view.bindToSuperview()
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: SettingsModeRoot.Load.ViewModel) {        
    }
    
    // MARK: Handlers
    @IBAction private func onSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let deviceMode = UserDeviceMode(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        
        switch deviceMode {
        case .main: setMasterController()
        case .follower: setFollowerController()
        }
    }
}

private extension UserDeviceMode {
    var title: String {
        switch self {
        case .follower: return "settings_mode_settings_follower".localized
        case .main: return "settings_mode_settings_master".localized
        }
    }
}

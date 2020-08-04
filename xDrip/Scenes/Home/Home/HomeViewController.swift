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
    func displayWarmUp(viewModel: Home.WarmUp.ViewModel)
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
    @IBOutlet private weak var warmUpLabel: UILabel!
    @IBOutlet private weak var warmUpLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var aboutGlucoseTitleLabel: UILabel!
    @IBOutlet private weak var aboutGlucoseContentLabel: UILabel!
    @IBOutlet private weak var bolusCarbsTopConstraint: NSLayoutConstraint!
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
    
    @IBAction private func toEntriesList(_ sender: UIButton) {
        let request = Home.ShowEntriesList.Request(entriesType: sender.tag == 1 ? .carbs : .bolus)
        interactor?.doShowEntriesList(request: request)
    }
    
    @IBAction private func onTimeFrameSegmentSelected() {
        let hours: Int
        switch timeLineSegmentView.selectedSegmentIndex {
        case 0: hours = 1
        case 1: hours = 3
        case 2: hours = 6
        case 3: hours = 12
        case 4: hours = 24
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
        glucoseChart.setTimeFrame(viewModel.timeInterval)
    }
    
    func displayGlucoseCurrentInfo(viewModel: Home.GlucoseCurrentInfo.ViewModel) {
        glucoseCurrentInfoView.setup(with: viewModel)
    }
    
    func displayBolusData(viewModel: Home.BolusDataUpdate.ViewModel) {
        bolusHistoryView.setup(with: viewModel)
        updateBolusCarbsTopConstraint()
    }
    
    func displayBolusChartTimeFrame(viewModel: Home.ChangeEntriesChartTimeFrame.ViewModel) {
        bolusHistoryView.setTimeFrame(viewModel.timeInterval, chartButtonTitle: viewModel.buttonTitle)
    }
    
    func displayCarbsData(viewModel: Home.CarbsDataUpdate.ViewModel) {
        carbsHistoryView.setup(with: viewModel)
        updateBolusCarbsTopConstraint()
    }
    
    func displayCarbsChartTimeFrame(viewModel: Home.ChangeEntriesChartTimeFrame.ViewModel) {
        carbsHistoryView.setTimeFrame(viewModel.timeInterval, chartButtonTitle: viewModel.buttonTitle)
    }
    
    func displayWarmUp(viewModel: Home.WarmUp.ViewModel) {
        if viewModel.shouldShowWarmUp {
            if warmUpLabel.isHidden {
                warmUpLabel.isHidden = false
                warmUpLabelTopConstraint.constant = 8.0
            }
            
            let timeLabel: String
            if viewModel.warmUpLeftHours > 0 {
                timeLabel = String(
                    format: "home_warmingup_time_label_hours".localized,
                    viewModel.warmUpLeftHours,
                    viewModel.warmUpLeftMinutes
                )
            } else {
                timeLabel = String(
                    format: "home_warmingup_time_label_minutes".localized,
                    viewModel.warmUpLeftMinutes
                )
            }
            
            let string = NSMutableAttributedString()
            string.append(
                NSAttributedString(
                    string: "home_warmingup_initial_label".localized,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                        .foregroundColor: UIColor.highEmphasisText
                    ]
                )
            )
            string.append(
                NSAttributedString(
                    string: timeLabel,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                        .foregroundColor: UIColor.tabBarRedColor
                    ]
                )
            )
            
            warmUpLabel.attributedText = string
        } else {
            warmUpLabel.isHidden = true
            warmUpLabel.attributedText = nil
            warmUpLabelTopConstraint.constant = 0.0
        }
    }
    
    private func updateBolusCarbsTopConstraint() {
        if bolusHistoryView.isHidden && carbsHistoryView.isHidden {
            bolusCarbsTopConstraint.constant = 0
        } else {
            bolusCarbsTopConstraint.constant = 16
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
    }
}

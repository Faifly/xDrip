//
//  StatsRootViewController.swift
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

protocol StatsRootDisplayLogic: AnyObject {
    func displayLoad(viewModel: StatsRoot.Load.ViewModel)
    func displayTableData(viewModel: StatsRoot.UpdateTableData.ViewModel)
    func displayChartData(viewModel: StatsRoot.UpdateChartData.ViewModel)
}

class StatsRootViewController: NibViewController, StatsRootDisplayLogic {
    var interactor: StatsRootBusinessLogic?
    var router: StatsRootDataPassing?
    
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
        let interactor = StatsRootInteractor()
        let presenter = StatsRootPresenter()
        let router = StatsRootRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.router = router
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: IB
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var chartView: StatsChartView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBAction private func onSegmentedControlValueChanged() {
        showSpinner()
        DispatchQueue.main.async {[weak self] in
            guard let self = self  else { return }
            let request = StatsRoot.UpdateTimeFrame.Request(
                timeFrame: StatsRoot.TimeFrame.allCases[self.segmentedControl.selectedSegmentIndex]
            )
            self.interactor?.doSelectTimeFrame(request: request)
        }
    }
    
    private func showSpinner() {
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    private func hideSpinner() {
        spinner.stopAnimating()
        spinner.isHidden = true
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doLoad()
    }
    
    // MARK: Do something
    
    private var cells: [StatsRoot.Cell] = []
    
    private func doLoad() {
        title = "stats_screen_title".localized
        setupNavigationItems()
        setupSegmentedControl()
        
        let request = StatsRoot.Load.Request()
        interactor?.doLoad(request: request)
    }
    
    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "close".localized,
            style: .plain,
            target: self,
            action: #selector(onCancelButtonTap)
        )
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        for (index, segment) in StatsRoot.TimeFrame.allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: segment.title, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc private func onCancelButtonTap() {
        let request = StatsRoot.Cancel.Request()
        interactor?.doCancel(request: request)
    }
    
    // MARK: Display
    
    func displayLoad(viewModel: StatsRoot.Load.ViewModel) {        
    }
    
    func displayTableData(viewModel: StatsRoot.UpdateTableData.ViewModel) {
        cells = viewModel.cells
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    func displayChartData(viewModel: StatsRoot.UpdateChartData.ViewModel) {
        chartView.update(with: viewModel.entries)
        hideSpinner()
    }
}

private extension StatsRoot.TimeFrame {
    var title: String {
        switch self {
        case .today: return "stats_timeframe_today".localized
        case .yesterday: return "stats_timeframe_yesterday".localized
        case .sevenDays: return "stats_timeframe_7_days".localized
        case .thirtyDays: return "stats_timeframe_30_days".localized
        case .nintyDays: return "stats_timeframe_90_days".localized
        }
    }
}

extension StatsRootViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = cells[indexPath.row].title
        cell.detailTextLabel?.text = cells[indexPath.row].value
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
}

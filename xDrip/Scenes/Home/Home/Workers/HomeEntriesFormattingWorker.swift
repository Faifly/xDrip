//
//  HomeEntriesFormattingWorker.swift
//  xDrip
//
//  Created by Dmitry on 6/26/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

 struct HomeEntry: BaseHomeEntryProtocol {
    let title: String
    let buttonTitle: String
    let entries: [BaseChartEntry]
    let unit: String
    let color: UIColor
}

protocol HomeEntriesFormattingWorkerProtocol {
    func formatBolusResponse(_ response: Home.BolusDataUpdate.Response) -> HomeEntry
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> HomeEntry
}

final class HomeEntriesFormattingWorker: HomeEntriesFormattingWorkerProtocol {
    func formatBolusResponse(_ response: Home.BolusDataUpdate.Response) -> HomeEntry {
        return HomeEntry(title: "Active Insulin",
                         buttonTitle: "14.49" + Root.EntryType.bolus.shortLabel + ">",
                         entries: response.bolusData,
                         unit: Root.EntryType.bolus.shortLabel,
                         color: .red)
    }
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> HomeEntry {
        return HomeEntry(title: "Active Carbohydrates",
                         buttonTitle: "40" + Root.EntryType.carbs.shortLabel + ">",
                         entries: response.carbsData,
                         unit: Root.EntryType.carbs.shortLabel,
                         color: .green)
    }
}

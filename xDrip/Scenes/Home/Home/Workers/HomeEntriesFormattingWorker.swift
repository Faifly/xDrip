//
//  HomeEntriesFormattingWorker.swift
//  xDrip
//
//  Created by Dmitry on 6/26/20.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

struct InsulinCarbEntry: BaseHomeEntryProtocol {
    let title: String
    let buttonTitle: String
    let entries: [BaseChartEntry]
    let unit: String
    let color: UIColor
}

protocol HomeEntriesFormattingWorkerProtocol {
    func formatBolusResponse(_ response: Home.BolusDataUpdate.Response) -> InsulinCarbEntry
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> InsulinCarbEntry
}

final class HomeEntriesFormattingWorker: HomeEntriesFormattingWorkerProtocol {
    func formatBolusResponse(_ response: Home.BolusDataUpdate.Response) -> InsulinCarbEntry {
        let entries = response.insulinData.map { BaseChartEntry(value: $0.amount, date: $0.date ?? Date()) }
        return InsulinCarbEntry(title: "Active Insulin",
                                buttonTitle: "14.49" + Root.EntryType.bolus.shortLabel + ">",
                                entries: entries,
                                unit: Root.EntryType.bolus.shortLabel,
                                color: .red)
    }
    func formatCarbsResponse(_ response: Home.CarbsDataUpdate.Response) -> InsulinCarbEntry {
        let entries = response.carbsData.map { BaseChartEntry(value: $0.amount, date: $0.date ?? Date()) }
        return InsulinCarbEntry(title: "Active Carbohydrates",
                                buttonTitle: "40" + Root.EntryType.carbs.shortLabel + ">",
                                entries: entries,
                                unit: Root.EntryType.carbs.shortLabel,
                                color: .green)
    }
}

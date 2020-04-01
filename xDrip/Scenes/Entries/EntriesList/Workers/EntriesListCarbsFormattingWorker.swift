//
//  EntriesListCarbsFormattingWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListCarbsFormattingWorker: EntriesListAbstractFormattingWorker, EntriesListFormattingWorker {
    
    func formatEntries(_ entries: [AbstractEntry]) -> [EntriesListTableViewCell.ViewModel] {
        let cellViewModels = entries.compactMap { transformToViewModel($0 as? CarbEntry) }
        
        return cellViewModels
    }
    
    private func transformToViewModel(_ entry: CarbEntry?) -> EntriesListTableViewCell.ViewModel? {
        guard let entry = entry else { return nil }
        
        let value = String(format: "%.02f g", entry.amount)
        let date = getDateString(for: entry)
        
        return EntriesListTableViewCell.ViewModel(value: value, date: date)
    }
}

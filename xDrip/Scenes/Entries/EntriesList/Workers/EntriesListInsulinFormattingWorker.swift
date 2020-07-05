//
//  EntriesListInsulinFormattingWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListInsulinFormattingWorker: EntriesListAbstractFormattingWorker, EntriesListFormattingWorker {
    func formatEntries(_ entries: [AbstractEntry]) -> [EntriesListTableViewCell.ViewModel] {
        let cellViewModels = entries.compactMap { transformToViewModel($0 as? InsulinEntry) }
        
        return cellViewModels
    }
    
    private func transformToViewModel(_ entry: InsulinEntry?) -> EntriesListTableViewCell.ViewModel? {
        guard let entry = entry else { return nil }
        
        let value = String(
            format: "%@ - " + "%.02f " + "entries_list_scene_carbs_insulin_unit".localized,
            (entry.type == .bolus ? "entries_list_bolus_entry_title" : "entries_list_basal_entry_title").localized,
            entry.amount
        )
        let date = getDateString(for: entry)
        
        return EntriesListTableViewCell.ViewModel(value: value, date: date)
    }
}

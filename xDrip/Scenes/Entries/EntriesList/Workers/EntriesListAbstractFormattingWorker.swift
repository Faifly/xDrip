//
//  EntriesListAbstractFormattingWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

class EntriesListAbstractFormattingWorker {
    func getDateString(for entry: AbstractEntry) -> String {
        guard let date = entry.entryDate else {
            return "entries_list_cell_no_date".localized
        }
        
        return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
    }
}

//
//  EntriesListInsulinPersistenceWorker.swift
//  xDrip
//
//  Created by Ivan Skoryk on 30.03.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EntriesListInsulinPersistenceWorker: EntriesListEntryPersistenceWorker {
    let type: InsulinType
    
    init(type: InsulinType) {
        self.type = type
    }
    private var insulinEntries: [InsulinEntry] = []
    
    func fetchEntries() -> [AbstractEntry] {
        switch type {
        case .bolus:
            insulinEntries = InsulinEntriesWorker.fetchAllBolusEntries()
            case .basal:
            insulinEntries = InsulinEntriesWorker.fetchAllBasalEntries()
        }
        return insulinEntries
    }

    func deleteEntry(_ index: Int) {
        let entry = insulinEntries.remove(at: index)
        InsulinEntriesWorker.deleteInsulinEntry(entry)
    }
}

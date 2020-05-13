//
//  EditTrainingFormattingWorker.swift
//  xDrip
//
//  Created by Vladislav Kliutko on 23.04.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class EditTrainingFormattingWorker {
    func transformToLocalEntry(_ entry: TrainingEntry?) -> EditTraining.LocalEntry {
        if let entry = entry {
            return [
                .duration: entry.duration as AnyObject,
                .intensity: entry.intensity as AnyObject,
                .dateTime: entry.date as AnyObject
            ]
        } else {
            return [
                .duration: TimeInterval.secondsPerMinute as AnyObject,
                .intensity: TrainingIntensity.default as AnyObject,
                .dateTime: Calendar.current.date(bySetting: Calendar.Component.second, value: 0, of: Date()) as AnyObject
            ]
        }
    }
    
    func transformToTrainingEntry(_ localEntry: EditTraining.LocalEntry?) -> TrainingEntry? {
        guard
            let localEntry = localEntry,
            let duration = localEntry[.duration] as? TimeInterval,
            let intensity = localEntry[.intensity] as? TrainingIntensity,
            let date = localEntry[.dateTime] as? Date else { return nil }
        
        return TrainingEntry(duration: duration,
                             intensity: intensity,
                             date: date)
    }
}

//
//  PumpService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 29.09.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import RealmSwift

struct PumpServiceConnectionInfo {
    let pumpID: String?
    let manufacturer: String?
    let model: String?
}

enum PumpSyncError: LocalizedError {
    case general
    case noDeviceInfo
    case noPumpInfo
    case pumpSuspended
    
    var localizedDescription: String {
        switch self {
        case .general:
            return "settings_pump_user_connection_error_general".localized
        case .noDeviceInfo:
            return "settings_pump_user_connection_error_no_device".localized
        case .noPumpInfo:
            return "settings_pump_user_connection_error_no_pump".localized
        case .pumpSuspended:
            return "settings_pump_user_connection_error_pump_suspended".localized
        }
    }
    
    var errorDescription: String? {
        return localizedDescription
    }
}

protocol PumpServiceLogic {
    func connectToNightscoutPump(nightscoutURL: URL,
                                 callback: @escaping (PumpServiceConnectionInfo?, PumpSyncError?) -> Void)
    func fetchPumpData()
}

final class PumpService: PumpServiceLogic {
    func connectToNightscoutPump(nightscoutURL: URL,
                                 callback: @escaping (PumpServiceConnectionInfo?, PumpSyncError?) -> Void) {
        let request = createDeviceStatusRequest(nightscoutURL)
        URLSession.shared.loggableDataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async { [weak self] in
                self?.handlePumpConnectionRequest(data: data, error: error, callback: callback)
            }
        }.resume()
    }
    
    func fetchPumpData() {
        guard let request = createGetTreatmentsRequest() else { return }
        URLSession.shared.loggableDataTask(with: request) { [weak self] data, _, _ in
            guard let data = data else { return }
            guard let convertedData = try? JSONDecoder().decode([CPumpBasalEntry].self, from: data) else { return }
            self?.parsePumpBasalEntries(convertedData)
        }.resume()
    }
    
    private func handlePumpConnectionRequest(data: Data?,
                                             error: Error?,
                                             callback: @escaping (PumpServiceConnectionInfo?, PumpSyncError?) -> Void) {
        guard let data = data, error == nil else {
            callback(nil, .general)
            return
        }
        guard let entries = try? JSONDecoder().decode([CDeviceStatus].self, from: data) else {
            callback(nil, .general)
            return
        }
        guard !entries.isEmpty else {
            callback(nil, .noDeviceInfo)
            return
        }
        guard let pumpInfo = entries.first(where: { $0.pump != nil })?.pump else {
            callback(nil, .noPumpInfo)
            return
        }
        guard !(pumpInfo.suspended ?? false) else {
            callback(nil, .pumpSuspended)
            return
        }
        let connectionInfo = PumpServiceConnectionInfo(
            pumpID: pumpInfo.pumpID,
            manufacturer: pumpInfo.manufacturer,
            model: pumpInfo.model
        )
        callback(connectionInfo, nil)
    }
    
    private func createDeviceStatusRequest(_ baseURL: URL) -> URLRequest {
        let url = baseURL.safeAppendingPathComponent("/api/v1/devicestatus")
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        return request
    }
    
    private func createGetTreatmentsRequest() -> URLRequest? {
        guard let baseURLString = User.current.settings.pumpSync.nightscoutURL else { return nil }
        guard let baseURL = URL(string: baseURLString) else { return nil }
        let url = baseURL.safeAppendingPathComponent("/api/v1/treatments")
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        return request
    }
    
    private func parsePumpBasalEntries(_ rawEntries: [CPumpBasalEntry]) {
        let rawTempBasal = rawEntries.filter { $0.eventType == "Temp Basal" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let entries = rawTempBasal.map { InsulinEntry(rawPumpEntry: $0, dateFormatter: dateFormatter) }
        
        DispatchQueue.main.async {
            Realm.shared.safeWrite {
                Realm.shared.add(entries, update: .all)
                InsulinEntriesWorker.updatedBasalEntry()
            }
        }
    }
}

private extension InsulinEntry {
    convenience init(rawPumpEntry: CPumpBasalEntry, dateFormatter: DateFormatter) {
        let date = dateFormatter.date(from: rawPumpEntry.timestamp ?? "") ?? Date()
        self.init(
            amount: 0.0,
            date: date,
            type: .pumpBasal,
            externalID: rawPumpEntry.id,
            duration: rawPumpEntry.duration ?? 0.0
        )
    }
}

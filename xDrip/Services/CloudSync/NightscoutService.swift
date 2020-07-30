//
//  NightscoutService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

final class NightscoutService {
    static let shared = NightscoutService()
    
    private var reachability = try? ReachabilityService()
    private var currentConnectType = ReachabilityService.Connection.unavailable
    
    private var requestQueue: [UploadRequest] = []
    
    private lazy var settingsObservers: [Any] = NotificationCenter.default.subscribe(
        forSettingsChange: [.followerAuthStatus]) {
            guard let settings = User.current.settings.nightscoutSync else { return }
            if settings.isFollowerAuthed {
                self.startFetchingFollowerData()
            } else {
                self.stopFetchingFollowerData()
            }
    }
    private lazy var lastFollowerFetchTime = GlucoseReading.allFollower.last?.date
    private var followerFetchTimer: Timer?
    private let requestFactory: UploadRequestFactoryLogic
    
    init() {
        requestFactory = UploadRequestFactory()
        _ = settingsObservers
        if let settings = User.current.settings.nightscoutSync, settings.isFollowerAuthed {
            startFetchingFollowerData()
        }
        
        reachability?.whenReachable = { [weak self] reachability in
            self?.currentConnectType = reachability.connection
            self?.scanForNotUploadedEntries()
        }
        reachability?.whenUnreachable = { [weak self] reachability in
            self?.currentConnectType = reachability.connection
        }
        
        try? reachability?.startNotifier()
    }
    
    deinit {
        reachability?.stopNotifier()
    }
    
    func scanForNotUploadedEntries() {
        guard let isEnabled = User.current.settings.nightscoutSync?.isEnabled, isEnabled else { return }
        scanForGlucoseEntries()
        scanForCalibrations()
        
        if User.current.settings.nightscoutSync?.useCellularData == false {
            guard self.currentConnectType != .cellular else { return }
        }
        runQueue()
    }
    
    func deleteCalibrations(_ calibrations: [Calibration]) {
        guard let isEnabled = User.current.settings.nightscoutSync?.isEnabled, isEnabled else { return }
        let requests = calibrations.compactMap { requestFactory.createDeleteCalibrationRequest($0) }
        requestQueue.append(contentsOf: requests)
        
        if User.current.settings.nightscoutSync?.useCellularData == false {
            guard self.currentConnectType != .cellular else { return }
        }
        runQueue()
    }
    
    private func scanForGlucoseEntries() {
        let all = GlucoseReading.allMaster
        let notUploaded = all.filter { $0.cloudUploadStatus == .notUploaded }
        let modified = all.filter { $0.cloudUploadStatus == .modified }
        
        for entry in notUploaded {
            guard !requestQueue.contains(where: {
                $0.itemID == entry.externalID && $0.type == .postGlucoseReading
            }) else { continue }
            guard let request = requestFactory.createNotUploadedGlucoseRequest(entry) else { return }
            requestQueue.append(request)
        }
        
        for entry in modified {
            if let index = requestQueue.firstIndex(where: {
                $0.itemID == entry.externalID && $0.type == .postGlucoseReading
            }) {
                requestQueue.remove(at: index)
            }
            
            if !requestQueue.contains(where: {
                $0.itemID == entry.externalID && $0.type == .deleteGlucoseReading
            }), let request = requestFactory.createDeleteReadingRequest(entry) {
                requestQueue.append(request)
            }
            
            if !requestQueue.contains(where: {
                $0.itemID == entry.externalID && $0.type == .modifyGlucoseReading
            }), var request = requestFactory.createModifiedGlucoseRequest(entry) {
                request.type = .modifyGlucoseReading
                requestQueue.append(request)
            }
        }
    }
    
    private func scanForCalibrations() {
        let notUploaded = Calibration.allForCurrentSensor.filter { !$0.isUploaded }
        for entry in notUploaded {
            guard !requestQueue.contains(where: {
                $0.itemID == entry.externalID && $0.type == .postCalibration
            }) else { continue }
            guard let request = requestFactory.createCalibrationRequest(entry) else { continue }
            requestQueue.append(request)
        }
    }
    
    func testNightscoutConnection(tryAuth: Bool, callback: @escaping (Bool, NightscoutError?) -> Void) {
        do {
            let request = try requestFactory.createTestConnectionRequest(tryAuth: tryAuth)
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                DispatchQueue.main.async {
                    guard let response = response as? HTTPURLResponse else {
                        callback(false, NightscoutError.cantConnect)
                        return
                    }
                    
                    if response.statusCode == 401 {
                        callback(false, NightscoutError.invalidAPISecret)
                    } else {
                        callback(response.statusCode == 200 && error == nil, NightscoutError.cantConnect)
                    }
                }
            }.resume()
        } catch {
            callback(false, error as? NightscoutError)
        }
    }
    
    private func runQueue() {
        guard !requestQueue.isEmpty else { return }
        let request = requestQueue[0]
        URLSession.shared.dataTask(with: request.request) { [weak self] _, _, error in
            guard let self = self else { return }
            guard error == nil else { return }
            let first = self.requestQueue.removeFirst()
            self.runQueue()
            
            DispatchQueue.main.async {
                switch first.type {
                case .postGlucoseReading, .modifyGlucoseReading:
                    GlucoseReading.markEntryAsUploaded(externalID: first.itemID)
                    
                case .deleteGlucoseReading, .deleteCalibration:
                    break
                    
                case .postCalibration:
                    Calibration.markCalibrationAsUploaded(itemID: first.itemID)
                }
            }
        }.resume()
    }
    
    private func startFetchingFollowerData() {
        followerFetchTimer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true) { _ in
                self.fetchFollowerData()
        }
        fetchFollowerData()
    }
    
    private func stopFetchingFollowerData() {
        followerFetchTimer?.invalidate()
        followerFetchTimer = nil
    }
    
    private func fetchFollowerData() {
        guard let request = requestFactory.createFetchFollowerDataRequest() else { return }
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            guard let entries = try? JSONDecoder().decode([CGlucoseReading].self, from: data) else { return }
            DispatchQueue.main.async {
                GlucoseReading.parseFollowerEntries(entries)
                CGMController.shared.notifyGlucoseChange()
            }
        }.resume()
    }
}

//
//  NightscoutService.swift
//  xDrip
//
//  Created by Artem Kalmykov on 08.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation
import AKUtils
import RealmSwift

final class NightscoutService {
    static let shared = NightscoutService()
    
    private var reachability = try? ReachabilityService()
    private var currentConnectType = ReachabilityService.Connection.unavailable
    
    private var requestQueue: [UploadRequest] = []
    private var isRequestInProgress = false
    
    private lazy var followerSettingsObserver: [Any] = NotificationCenter.default.subscribe(
        forSettingsChange: [.followerAuthStatus]) {
            guard let settings = User.current.settings.nightscoutSync else { return }
            if settings.isFollowerAuthed {
                self.startFetchingFollowerData()
            } else {
                self.stopFetchingFollowerData()
            }
    }
    
    private lazy var pumpSyncObserver: [Any] = NotificationCenter.default.subscribe(
        forSettingsChange: [.pumpSync]) {
            guard let settings = User.current.settings.pumpSync else { return }
            if settings.isEnabled {
                self.startFetchingPumpData()
            } else {
                self.stopFetchingPumpData()
            }
    }
    
    private lazy var downloadDataSettingsObserver: [Any] = NotificationCenter.default.subscribe(
        forSettingsChange: [.downloadData]) {
            guard let settings = User.current.settings.nightscoutSync else { return }
            if settings.downloadData {
                self.startFetchingTreatments()
            } else {
                self.stopFetchingTreatments()
            }
    }
    
    private lazy var uploadTreatmentsSettingsObserver: [Any] = NotificationCenter.default.subscribe(
        forSettingsChange: [.uploadTreatments]) {
            guard let settings = User.current.settings.nightscoutSync else { return }
            if settings.uploadTreatments {
                self.scanForNotUploadedTreatments()
            }
    }
    private lazy var lastFollowerFetchTime = GlucoseReading.allFollower.last?.date
    private lazy var pumpService: PumpServiceLogic = PumpService()
    private var followerFetchTimer: Timer?
    private var treatmentsFetchTimer: Timer?
    private var pumpFetchTimer: Timer?
    private let requestFactory: UploadRequestFactoryLogic
    
    var isPaused = false
    
    init() {
        requestFactory = UploadRequestFactory()
        _ = followerSettingsObserver
        _ = downloadDataSettingsObserver
        _ = uploadTreatmentsSettingsObserver
        if let settings = User.current.settings.nightscoutSync, settings.isFollowerAuthed {
            startFetchingFollowerData()
        }
        
        if let settings = User.current.settings.nightscoutSync, settings.downloadData {
            startFetchingTreatments()
        }
        
        if User.current.settings.pumpSync?.isEnabled ?? false {
            startFetchingPumpData()
        }
        
        reachability?.whenReachable = { [weak self] reachability in
            self?.currentConnectType = reachability.connection
            self?.runQueue()
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
        LogController.log(message: "[NighscoutService]: Started %@.", type: .info, #function)
        guard let isEnabled = User.current.settings.nightscoutSync?.isEnabled, isEnabled else {
            LogController.log(
                message: "[NighscoutService]: Aborting %@ because sync is disabled.",
                type: .info,
                #function
            )
            return
        }
        
        scanForGlucoseEntries()
        scanForCalibrations()
        
        runQueue()
    }
    
    func scanForNotUploadedTreatments() {
        LogController.log(message: "[NighscoutService]: Started %@.", type: .info, #function)
        guard let settings = User.current.settings.nightscoutSync,
            settings.isEnabled, settings.uploadTreatments else {
                LogController.log(
                    message: "[NighscoutService]: Aborting %@ because sync or uploadTreatments is disabled.",
                    type: .info,
                    #function
                )
                return
        }
        
        scanForTreatments(treatmentType: .carbs)
        scanForTreatments(treatmentType: .bolus)
        scanForTreatments(treatmentType: .basal)
        scanForTreatments(treatmentType: .training)
        
        runQueue()
    }
    
    func deleteCalibrations(_ calibrations: [Calibration]) {
        LogController.log(message: "[NighscoutService]: Try to %@.", type: .info, #function)
        guard let isEnabled = User.current.settings.nightscoutSync?.isEnabled, isEnabled else {
            LogController.log(
                message: "[NighscoutService]: Failed to %@ because sync is disabled.",
                type: .info,
                #function
            )
            return
        }
        let requests = calibrations.compactMap { requestFactory.createDeleteCalibrationRequest($0) }
        requestQueue.append(contentsOf: requests)
        
        runQueue()
    }
    
    private func scanForGlucoseEntries() {
        LogController.log(message: "[NighscoutService]: Started %@.", type: .info, #function)
        let all = GlucoseReading.allMaster
        let notUploaded = Array(all.filter("rawCloudUploadStatus == 1"))
        let modified = Array(all.filter("rawCloudUploadStatus == 2"))
        
        LogController.log(
            message: "[NighscoutService]: Found %d not uploaded and %d modified entries",
            type: .info,
            notUploaded.count,
            modified.count
        )
        
        let entries = notUploaded.filter { entry in
            !requestQueue.contains(where: { requset in
                guard let externalID = entry.externalID else { return false }
                return requset.itemIDs.contains(externalID) && requset.type == .postGlucoseReading
            })
        }
        
        guard let request = requestFactory.createNotUploadedGlucoseRequest(entries) else { return }
        requestQueue.append(request)
        
        for entry in modified {
            if let index = requestQueue.firstIndex(where: {
                guard let externalID = entry.externalID else { return false }
                return $0.itemIDs.contains(externalID) && $0.type == .postGlucoseReading
            }) {
                requestQueue.remove(at: index)
            }
            
            if !requestQueue.contains(where: {
                guard let externalID = entry.externalID else { return false }
                return $0.itemIDs.contains(externalID) && $0.type == .deleteGlucoseReading
            }), let request = requestFactory.createDeleteReadingRequest(entry) {
                requestQueue.append(request)
            }
            
            if !requestQueue.contains(where: {
                guard let externalID = entry.externalID else { return false }
                return $0.itemIDs.contains(externalID) && $0.type == .modifyGlucoseReading
            }), var request = requestFactory.createModifiedGlucoseRequest(entry) {
                request.type = .modifyGlucoseReading
                requestQueue.append(request)
            }
        }
    }
    
    private func scanForCalibrations() {
        LogController.log(message: "[NighscoutService]: Started %@", type: .info, #function)
        let notUploaded = Calibration.allForCurrentSensor.filter { !$0.isUploaded }
        for entry in notUploaded {
            guard !requestQueue.contains(where: {
                guard let externalID = entry.externalID else { return false }
                return $0.itemIDs.contains(externalID) && $0.type == .postCalibration
            }) else { continue }
            guard let request = requestFactory.createCalibrationRequest(entry) else { continue }
            requestQueue.append(request)
        }
    }
    
    private func scanForTreatments(treatmentType: TreatmentType) {
        LogController.log(message: "[NighscoutService]: Started %@.", type: .info, #function)
        let all: [TreatmentEntryProtocol]
        
        switch treatmentType {
        case .carbs:
            all = CarbEntriesWorker.fetchAllCarbEntries()
        case .bolus:
            all = InsulinEntriesWorker.fetchAllBolusEntries()
        case .basal:
            all = InsulinEntriesWorker.fetchAllBasalEntries()
        case .training:
            all = TrainingEntriesWorker.fetchAllTrainings()
        }
        
        let notUploaded = all.filter { $0.cloudUploadStatus == .notUploaded }
        let modified = all.filter { $0.cloudUploadStatus == .modified }
        let deleted = all.filter { $0.cloudUploadStatus == .waitingForDeletion }
        
        LogController.log(
            message: "[NighscoutService]: Found %d not uploaded and %d modified treatments and %d deleted treatments",
            type: .info,
            notUploaded.count,
            modified.count,
            deleted.count
        )
        
        checkNotUploadedTreatments(notUploaded, treatmentType)
        
        checkModifiedTreatments(modified, treatmentType)
        
        checkDeletedTreatments(deleted, treatmentType)
    }
    
    private func checkNotUploadedTreatments(_ notUploaded: [TreatmentEntryProtocol], _ treatmentType: TreatmentType) {
        let postRequestType = treatmentType.getUploadRequestTypeFor(requestType: .post)
        for entry in notUploaded {
            guard !requestQueue.contains(where: {
            $0.itemIDs.contains(entry.externalID) && $0.type == postRequestType
            }) else { continue }
            
            guard let request = requestFactory.createNotUploadedTreatmentRequest(
                CTreatment(entry: entry, treatmentType: treatmentType), requestType: postRequestType) else {
                    return }
            requestQueue.append(request)
        }
    }
    
    private func checkModifiedTreatments(_ modified: [TreatmentEntryProtocol], _ treatmentType: TreatmentType) {
        let postRequestType = treatmentType.getUploadRequestTypeFor(requestType: .post)
        let modifyRequestType = treatmentType.getUploadRequestTypeFor(requestType: .modify)
        for entry in modified {
            if let index = requestQueue.firstIndex(where: {
                $0.itemIDs.contains(entry.externalID) && $0.type == postRequestType
            }) {
                requestQueue.remove(at: index)
            }
            
            if !requestQueue.contains(where: {
                $0.itemIDs.contains(entry.externalID) && $0.type == modifyRequestType
            }), let request = requestFactory.createModifiedTreatmentRequest(
                CTreatment(entry: entry, treatmentType: treatmentType), requestType: modifyRequestType) {
                requestQueue.append(request)
            }
        }
    }
    
    private func checkDeletedTreatments(_ deleted: [TreatmentEntryProtocol], _ treatmentType: TreatmentType) {
        let postRequestType = treatmentType.getUploadRequestTypeFor(requestType: .post)
        let deleteRequestType = treatmentType.getUploadRequestTypeFor(requestType: .delete)
        for entry in deleted {
            if let index = requestQueue.firstIndex(where: {
                $0.itemIDs.contains(entry.externalID) && $0.type == postRequestType
            }) {
                requestQueue.remove(at: index)
            }
            
            if !requestQueue.contains(where: { $0.itemIDs.contains(entry.externalID) && $0.type == deleteRequestType
            }) {
                guard let request = requestFactory.createDeleteTreatmentRequest(entry.externalID,
                                                                                requestType: deleteRequestType) else {
                                                                                    return }
                self.requestQueue.append(request)
                self.runQueue()
            }
        }
    }
    
    func testNightscoutConnection(tryAuth: Bool, callback: @escaping (Bool, NightscoutError?) -> Void) {
        LogController.log(message: "[NighscoutService]: Try to %@.", type: .info, #function)
        do {
            let request = try requestFactory.createTestConnectionRequest(tryAuth: tryAuth)
            
            URLSession.shared.loggableDataTask(with: request) { _, response, error in
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
        guard checkUseCellular() else {
            LogController.log(
                message: "[NighscoutService]: Aborting run queue because not allowed to use cellular data.",
                type: .info
            )
            return
        }
        guard checkSkipLANUploads() else {
            LogController.log(
                message: "[NighscoutService]: Aborting run queue because skip LAN uploads enabled.",
                type: .info
            )
            return
        }
        guard !requestQueue.isEmpty else { return }
        guard !isPaused else { return }
        guard !isRequestInProgress else { return }
        
        isRequestInProgress = true
        let request = requestQueue[0]
        URLSession.shared.loggableDataTask(with: request.request) { [weak self] _, _, error in
            guard let self = self else { return }
            guard error == nil else { return }
            let first = self.requestQueue.removeFirst()
            NightscoutRequestCompleter.completeRequest(first)
            self.isRequestInProgress = false
            self.runQueue()
        }.resume()
    }
    
    private func startFetchingFollowerData() {
        LogController.log(message: "[NighscoutService]: Started fetching follower data.", type: .info)
        followerFetchTimer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true) { _ in
                self.fetchFollowerData()
        }
        fetchFollowerData()
    }
    
    private func startFetchingTreatments() {
        LogController.log(message: "[NighscoutService]: Started fetching treatments data.", type: .info)
        treatmentsFetchTimer = Timer.scheduledTimer(
            withTimeInterval: 60.0,
            repeats: true) { _ in
                if let settings = User.current.settings.nightscoutSync, settings.isEnabled, settings.downloadData {
                    self.fetchTreatments()
                }
        }
        fetchTreatments()
    }
    
    private func startFetchingPumpData() {
        LogController.log(message: "[NighscoutService]: Started fetching pump data.", type: .info)
        pumpFetchTimer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true, block: { _ in
            if User.current.settings.pumpSync.isEnabled {
                self.pumpService.fetchPumpData()
            }
        })
        pumpService.fetchPumpData()
    }
    
    private func stopFetchingPumpData() {
        LogController.log(message: "[NighscoutService]: Stopped fetching pump data.", type: .info)
        pumpFetchTimer?.invalidate()
        pumpFetchTimer = nil
    }
    
    private func stopFetchingFollowerData() {
        LogController.log(message: "[NighscoutService]: Stopped fetching follower data.", type: .info)
        followerFetchTimer?.invalidate()
        followerFetchTimer = nil
    }
    
    private func stopFetchingTreatments() {
        LogController.log(message: "[NighscoutService]: Stopped fetching treatments.", type: .info)
        treatmentsFetchTimer?.invalidate()
        treatmentsFetchTimer = nil
    }
    
    private func fetchFollowerData() {
        LogController.log(message: "[NighscoutService]: Try to %@.", type: .info, #function)
        guard let request = requestFactory.createFetchFollowerDataRequest() else { return }
        URLSession.shared.loggableDataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            guard let entries = try? JSONDecoder().decode([CGlucoseReading].self, from: data) else { return }
            DispatchQueue.main.async {
                let allFollower = GlucoseReading.allFollower
                let readings = GlucoseReading.parseFollowerEntries(entries).sorted(by: { $0.date >? $1.date })
                let newReadings = readings.filter { reading -> Bool in
                    !allFollower.contains(where: { $0.externalID == reading.externalID })
                }.sorted(by: { $0.date >? $1.date })
                CGMController.shared.notifyGlucoseChange(newReadings.first)
            }
        }.resume()
    }
    
    private func fetchTreatments() {
        LogController.log(message: "[NighscoutService]: Try to %@.", type: .info, #function)
        guard let request = requestFactory.createFetchTreatmentsRequest() else { return }
        URLSession.shared.loggableDataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            guard let entries = try? JSONDecoder().decode([CTreatment].self, from: data) else { return }
            DispatchQueue.main.async {
                CTreatment.parseTreatmentsToEntries(treatments: entries)
            }
        }.resume()
    }
    
    private func checkUseCellular() -> Bool {
        if User.currentAsync?.settings.nightscoutSync?.useCellularData == false {
            guard currentConnectType != .cellular else { return false }
        }
        
        return true
    }
    
    private func checkSkipLANUploads() -> Bool {
        if User.currentAsync?.settings.nightscoutSync?.skipLANUploads == true {
            guard let baseURLString = User.currentAsync?.settings.nightscoutSync?.baseURL else { return false }
            guard let baseURL = URL(string: baseURLString) else { return false }
            if baseURL.host?.hasPrefix("192.168.") == true && currentConnectType != .wifi {
                return false
            }
        }
        
        return true
    }
    
    func sendDeviceStatus() {
        LogController.log(message: "[NightscoutService]: Try to %@.", type: .info, #function)
        guard let request = requestFactory.createDeviceStatusRequest() else { return }
        URLSession.shared.loggableDataTask(with: request).resume()
    }
}

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
    
    init() {
        _ = settingsObservers
        if let settings = User.current.settings.nightscoutSync, settings.isFollowerAuthed {
            startFetchingFollowerData()
        }
    }
    
    func scanForNotUploadedEntries() {
        guard let isEnabled = User.current.settings.nightscoutSync?.isEnabled, isEnabled else { return }
        let all = GlucoseReading.allMaster
        let notUploaded = all.filter { $0.cloudUploadStatus == .notUploaded }
            
        for entry in notUploaded {
            guard !self.requestQueue.contains(where: { $0.itemID == entry.externalID }) else { continue }
            guard let request = self.createNotUploadedGlucoseRequest(entry) else { return }
            self.requestQueue.append(request)
        }
        
        self.runQueue()
    }
    
    func testNightscoutConnection(tryAuth: Bool, callback: @escaping (Bool, NightscoutError?) -> Void) {
        do {
            guard var request = try createPostEntriesRequest(appendSecret: tryAuth) else {
                callback(false, NightscoutError.invalidURL)
                return
            }
            
            request.timeoutInterval = 10.0
            if tryAuth {
                request.httpBody = "[{\"date\":1}]".data(using: .utf8)
            }
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
            }
            .resume()
        } catch {
            callback(false, error as? NightscoutError)
        }
    }
    
    private func createNotUploadedGlucoseRequest(_ entry: GlucoseReading) -> UploadRequest? {
        guard var request = try? createPostEntriesRequest() else { return nil }
        let codableEntry = CGlucoseReading(reading: entry)
        request.httpBody = try? JSONEncoder().encode([codableEntry])
        
        return UploadRequest(request: request, itemID: entry.externalID ?? "")
    }
    
    private func createPostEntriesRequest(appendSecret: Bool = true) throws -> URLRequest? {
        guard let baseURLString = User.current.settings.nightscoutSync?.baseURL else {
            throw NightscoutError.invalidURL
        }
        guard let baseURL = URL(string: baseURLString) else {
            throw NightscoutError.invalidURL
        }
        
        let url = baseURL.appendingPathComponent("/api/v1/entries.json")
        var request = URLRequest(url: url)
        
        if appendSecret {
            guard let apiSecret = User.current.settings.nightscoutSync?.apiSecret else {
                throw NightscoutError.noAPISecret
            }
            guard !apiSecret.isEmpty else {
                throw NightscoutError.noAPISecret
            }
            
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "API-SECRET": apiSecret.sha1
            ]
        } else {
            request.httpMethod = "GET"
        }
        
        return request
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
                GlucoseReading.markEntryAsUploaded(externalID: first.itemID)
            }
        }
        .resume()
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
        guard let settings = User.current.settings.nightscoutSync else { return }
        guard settings.isFollowerAuthed else { return }
        guard var request = try? createPostEntriesRequest(appendSecret: false) else { return }
        guard let url = request.url else { return }
        request.url = URL(string: url.absoluteString + "?count=50")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            guard let entries = try? JSONDecoder().decode([CGlucoseReading].self, from: data) else { return }
            DispatchQueue.main.async {
                GlucoseReading.parseFollowerEntries(entries)
                CGMController.shared.notifyGlucoseChange()
            }
        }
        .resume()
    }
}

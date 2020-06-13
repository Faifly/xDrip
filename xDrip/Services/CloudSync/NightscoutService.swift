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
    
    func scanForNotUploadedEntries() {
        guard let isEnabled = User.current.settings.nightscoutSync?.isEnabled, isEnabled else { return }
        let all = GlucoseReading.all
        let notUploaded = all.filter { $0.cloudUploadStatus == .notUploaded }
            
        for entry in notUploaded {
            guard !self.requestQueue.contains(where: { $0.itemID == entry.externalID }) else { continue }
            guard let request = self.createNotUploadedGlucoseRequest(entry) else { return }
            self.requestQueue.append(request)
        }
        
        self.runQueue()
    }
    
    func testNightscoutConnection(callback: @escaping (Bool, NightscoutError?) -> Void) {
        do {
            guard var request = try createPostEntriesRequest() else {
                callback(false, NightscoutError.invalidURL)
                return
            }
            
            request.timeoutInterval = 10.0
            request.httpBody = "[{\"date\":1}]".data(using: .utf8)
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
    
    private func createPostEntriesRequest() throws -> URLRequest? {
        guard let baseURLString = User.current.settings.nightscoutSync?.baseURL else {
            throw NightscoutError.invalidURL
        }
        guard let baseURL = URL(string: baseURLString) else {
            throw NightscoutError.invalidURL
        }
        guard let apiSecret = User.current.settings.nightscoutSync?.apiSecret else {
            throw NightscoutError.noAPISecret
        }
        guard !apiSecret.isEmpty else {
            throw NightscoutError.noAPISecret
        }
        
        let url = baseURL.appendingPathComponent("/api/v1/entries")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "API-SECRET": apiSecret.sha1,
            "Content-Type": "application/json"
        ]
        
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
}

//
//  UploadRequestFactory.swift
//  xDrip
//
//  Created by Artem Kalmykov on 15.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

protocol UploadRequestFactoryLogic {
    func createNotUploadedGlucoseRequest(_ entry: GlucoseReading) -> UploadRequest?
    func createModifiedGlucoseRequest(_ entry: GlucoseReading) -> UploadRequest?
    func createDeleteReadingRequest(_ entry: GlucoseReading) -> UploadRequest?
    func createTestConnectionRequest(tryAuth: Bool) throws -> URLRequest
    func createFetchFollowerDataRequest() -> URLRequest?
}

final class UploadRequestFactory: UploadRequestFactoryLogic {
    func createNotUploadedGlucoseRequest(_ entry: GlucoseReading) -> UploadRequest? {
        guard var request = try? createEntriesRequest() else { return nil }
        let codableEntry = CGlucoseReading(reading: entry)
        request.httpBody = try? JSONEncoder().encode([codableEntry])
        
        return UploadRequest(request: request, itemID: entry.externalID ?? "", type: .postGlucoseReading)
    }
    
    func createModifiedGlucoseRequest(_ entry: GlucoseReading) -> UploadRequest? {
        var request = createNotUploadedGlucoseRequest(entry)
        request?.type = .modifyGlucoseReading
        return request
    }
    
    func createDeleteReadingRequest(_ entry: GlucoseReading) -> UploadRequest? {
        guard var request = try? createEntriesRequest() else { return nil }
        guard let url = request.url else { return nil }
        guard let itemID = entry.externalID else { return nil }
        guard let date = entry.date else { return nil }
        request.url = URL(string: url.absoluteString + "?find[date]=\(Int64(date.timeIntervalSince1970 * 1000.0))")
        request.httpMethod = "DELETE"
        return UploadRequest(request: request, itemID: itemID, type: .deleteGlucoseReading)
    }
    
    func createTestConnectionRequest(tryAuth: Bool) throws -> URLRequest {
        guard var request = try createEntriesRequest(appendSecret: tryAuth) else {
            throw NightscoutError.invalidURL
        }
        
        request.timeoutInterval = 10.0
        if tryAuth {
            request.httpBody = "[{\"date\":1}]".data(using: .utf8)
        }
        
        return request
    }
    
    func createFetchFollowerDataRequest() -> URLRequest? {
        guard let settings = User.current.settings.nightscoutSync else { return nil }
        guard settings.isFollowerAuthed else { return nil }
        guard var request = try? createEntriesRequest(appendSecret: false) else { return nil }
        guard let url = request.url else { return nil }
        request.url = URL(string: url.absoluteString + "?count=50")
        request.httpMethod = "GET"
        return request
    }
    
    private func createEntriesRequest(appendSecret: Bool = true) throws -> URLRequest? {
        guard let baseURLString = User.current.settings.nightscoutSync?.baseURL else {
            throw NightscoutError.invalidURL
        }
        guard let baseURL = URL(string: baseURLString) else {
            throw NightscoutError.invalidURL
        }
        
        let url = baseURL.appendingPathComponent("/api/v1/entries.json")
        var request = URLRequest(url: url)
        
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        
        if appendSecret {
            guard let apiSecret = User.current.settings.nightscoutSync?.apiSecret else {
                throw NightscoutError.noAPISecret
            }
            guard !apiSecret.isEmpty else {
                throw NightscoutError.noAPISecret
            }
            
            request.httpMethod = "POST"
            var headers = request.allHTTPHeaderFields
            headers?["API-SECRET"] = apiSecret.sha1
            request.allHTTPHeaderFields = headers
        } else {
            request.httpMethod = "GET"
        }
        
        return request
    }
}

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
    func createCalibrationRequest(_ calibration: Calibration) -> UploadRequest?
    func createDeleteCalibrationRequest(_ calibration: Calibration) -> UploadRequest?
    func createTestConnectionRequest(tryAuth: Bool) throws -> URLRequest
    func createFetchFollowerDataRequest() -> URLRequest?
    func createFetchTreatmentsRequest() -> URLRequest?
    func createDeviceStatusRequest() -> URLRequest?
    func createNotUploadedTreatmentRequest(_ entry: CTreatment, requestType: UploadRequestType) -> UploadRequest?
    func createDeleteTreatmentRequest(_ uuid: String, requestType: UploadRequestType) -> UploadRequest?
    func createModifiedTreatmentRequest(_ entry: CTreatment, requestType: UploadRequestType) -> UploadRequest?
}

final class UploadRequestFactory: UploadRequestFactoryLogic {
    func createNotUploadedGlucoseRequest(_ entry: GlucoseReading) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard var request = try? createEntriesRequest() else {
            LogController.log(message: "[UploadRequestFactory]: Failed to %@.", type: .info, #function)
            return nil
        }
        let codableEntry = CGlucoseReading(reading: entry)
        request.httpBody = try? JSONEncoder().encode([codableEntry])
        
        return UploadRequest(request: request, itemID: entry.externalID ?? "", type: .postGlucoseReading)
    }
    
    func createModifiedGlucoseRequest(_ entry: GlucoseReading) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        var request = createNotUploadedGlucoseRequest(entry)
        request?.type = .modifyGlucoseReading
        return request
    }
    
    func createDeleteReadingRequest(_ entry: GlucoseReading) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        return createDeleteRequest(
            itemID: entry.externalID,
            date: entry.date,
            type: .deleteGlucoseReading
        )
    }
    
    func createCalibrationRequest(_ calibration: Calibration) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard var request = try? createEntriesRequest() else {
            LogController.log(message: "[UploadRequestFactory]: Failed to %@.", type: .info, #function)
            return nil
        }
        let codableEntry = CCalibration(calibration: calibration)
        request.httpBody = try? JSONEncoder().encode([codableEntry])
        return UploadRequest(request: request, itemID: calibration.externalID ?? "", type: .postCalibration)
    }
    
    func createDeleteCalibrationRequest(_ calibration: Calibration) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        return createDeleteRequest(
            itemID: calibration.externalID,
            date: calibration.date,
            type: .deleteCalibration
        )
    }
    
    func createTestConnectionRequest(tryAuth: Bool) throws -> URLRequest {
        LogController.log(message: "[UploadRequestFactory]: Try to %@", type: .info, #function)
        if !tryAuth {
            guard var request = try createEntriesRequest(appendSecret: false) else {
                LogController.log(
                    message: "[UploadRequestFactory]: Failed to %@ because of invalid base URL.",
                    type: .info,
                    #function
                )
                throw NightscoutError.invalidURL
            }
            request.timeoutInterval = 10.0
            return request
        } else {
            guard let baseURLString = User.current.settings.nightscoutSync?.baseURL else {
                LogController.log(
                    message: "[UploadRequestFactory]: Failed to %@ because of no base URL provided.",
                    type: .info,
                    #function
                )
                throw NightscoutError.invalidURL
            }
            guard let baseURL = URL(string: baseURLString) else {
                LogController.log(
                    message: "[UploadRequestFactory]: Failed to %@ because of invalid base URL.",
                    type: .info,
                    #function
                )
                throw NightscoutError.invalidURL
            }
            let url = baseURL.safeAppendingPathComponent("/api/v1/experiments/test")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 10.0
            
            guard let apiSecret = User.current.settings.nightscoutSync?.apiSecret, !apiSecret.isEmpty else {
                LogController.log(
                    message: "[UploadRequestFactory]: Failed to %@ because of no API Secret provided.",
                    type: .info,
                    #function
                )
                throw NightscoutError.noAPISecret
            }
            request.allHTTPHeaderFields = createHeaders(apiSecret: apiSecret.sha1)
            
            return request
        }
    }
    
    func createFetchFollowerDataRequest() -> URLRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard let settings = User.current.settings.nightscoutSync else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because sync is disabled.",
                type: .info,
                #function
            )
            return nil
        }
        guard settings.isFollowerAuthed else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because follower is not authed.",
                type: .info,
                #function
            )
            return nil
        }
        guard var request = try? createEntriesRequest(appendSecret: false) else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@.",
                type: .info,
                #function
            )
            return nil
        }
        guard let url = request.url else { return nil }
        request.url = URL(string: url.absoluteString + "?count=50")
        request.httpMethod = "GET"
        return request
    }
    
    private func createDeleteRequest(itemID: String?, date: Date?, type: UploadRequestType) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard var request = try? createEntriesRequest() else {
            LogController.log(message: "[UploadRequestFactory]: Failed to %@.", type: .info, #function)
            return nil
        }
        guard let url = request.url else { return nil }
        guard let itemID = itemID else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because of no itemID provided.",
                type: .info,
                #function
            )
            return nil
        }
        guard let date = date else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because of no date provided.",
                type: .info,
                #function
            )
            return nil
        }
        request.url = URL(string: url.absoluteString + "?find[date]=\(Int64(date.timeIntervalSince1970 * 1000.0))")
        request.httpMethod = "DELETE"
        return UploadRequest(request: request, itemID: itemID, type: type)
    }
    
    private func createEntriesRequest(appendSecret: Bool = true) throws -> URLRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard let baseURLString = User.current.settings.nightscoutSync?.baseURL else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because no base url provided.",
                type: .info,
                #function
            )
            throw NightscoutError.invalidURL
        }
        guard let baseURL = URL(string: baseURLString) else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because of invalid base url.",
                type: .info,
                #function
            )
            throw NightscoutError.invalidURL
        }
        let url = baseURL.safeAppendingPathComponent("/api/v1/entries.json")
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = createHeaders()
        
        if appendSecret {
            guard let apiSecret = User.current.settings.nightscoutSync?.apiSecret else {
                LogController.log(
                    message: "[UploadRequestFactory]: Failed to %@ because of no api secret provided.",
                    type: .info,
                    #function
                )
                throw NightscoutError.noAPISecret
            }
            guard !apiSecret.isEmpty else {
                LogController.log(
                    message: "[UploadRequestFactory]: Failed to %@ because of no api secret provided.",
                    type: .info,
                    #function
                )
                throw NightscoutError.noAPISecret
            }
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = createHeaders(apiSecret: apiSecret.sha1)
        } else {
            request.httpMethod = "GET"
        }
        
        return request
    }
    
    func createDeviceStatusRequest() -> URLRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        let settings = User.current.settings.nightscoutSync
        guard settings?.uploadBridgeBattery == true else {
            LogController.log(
                message: "[UploadRequestFactory]: Aborting %@ because upload bridge battery not enabled.",
                type: .info,
                #function
            )
            return nil
        }
        guard let baseURLString = settings?.baseURL else {
            LogController.log(
                message: "[UploadRequestFactory]: Aborting %@ because no base URL string provided.",
                type: .info,
                #function
            )
            return nil
        }
        guard let baseURL = URL(string: baseURLString) else {
            LogController.log(
                message: "[UploadRequestFactory]: Aborting %@ because can't create url from base URL string.",
                type: .info,
                #function
            )
            return nil
        }
        guard let apiSecret = settings?.apiSecret else {
            LogController.log(
                message: "[UploadRequestFactory]: Aborting %@ because no API Secret provided.",
                type: .info,
                #function
            )
            return nil
        }
        
        let url = baseURL.safeAppendingPathComponent("/api/v1/devicestatus")
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = createHeaders(apiSecret: apiSecret.sha1)
        
        let data: [String: Any] = [
            "device": "xDrip iOS",
            "uploader": [
                "battery": BridgeBatteryService.getBatteryLevel()
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        request.httpMethod = "POST"
        
        return request
    }
    
    private func createHeaders(apiSecret: String? = nil) -> [String: String] {
        var headers = [
            "Content-Type": "application/json"
        ]
        
        if let secret = apiSecret {
            headers["API-SECRET"] = secret
        }
        
        return headers
    }
    
    func createNotUploadedTreatmentRequest(_ entry: CTreatment, requestType: UploadRequestType) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard var request = try? createTreatmentsRequest() else {
            LogController.log(message: "[UploadRequestFactory]: Failed to %@.", type: .info, #function)
            return nil
        }
        request.httpBody = try? JSONEncoder().encode(entry)
        
        return UploadRequest(request: request, itemID: entry.uuid ?? "", type: requestType)
    }
    
    func createModifiedTreatmentRequest(_ entry: CTreatment, requestType: UploadRequestType) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        var request = createNotUploadedTreatmentRequest(entry, requestType: requestType)
        
        request?.type = requestType
        return request
    }
    
    func createDeleteTreatmentRequest(_ uuid: String, requestType: UploadRequestType) -> UploadRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        
        guard var request = try? deleteTreatmentRequest() else {
            LogController.log(message: "[UploadRequestFactory]: Failed to %@.", type: .info, #function)
            return nil
        }
        guard let url = request.url else { return nil }
        
        request.url = url.safeAppendingPathComponent("/\(CTreatment.getIDFromUUID(uuid: uuid))")
        
        return UploadRequest(request: request, itemID: uuid, type: requestType)
    }
    
    func createFetchTreatmentsRequest() -> URLRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard let settings = User.current.settings.nightscoutSync, settings.isEnabled else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because sync is disabled.",
                type: .info,
                #function
            )
            return nil
        }
        
        guard let request = try? createTreatmentsRequest(appendSecret: false) else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@.",
                type: .info,
                #function
            )
            return nil
        }
        
        return request
    }
        
    private func createTreatmentsRequest(appendSecret: Bool = true) throws -> URLRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard let baseURLString = User.current.settings.nightscoutSync?.baseURL else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because no base url provided.",
                type: .info,
                #function
            )
            throw NightscoutError.invalidURL
        }
        guard let baseURL = URL(string: baseURLString) else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because of invalid base url.",
                type: .info,
                #function
            )
            throw NightscoutError.invalidURL
        }
        let url = baseURL.safeAppendingPathComponent("/api/v1/treatments")
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = createHeaders()
        
        if appendSecret {
            guard let apiSecret = User.current.settings.nightscoutSync?.apiSecret else {
                LogController.log(
                    message: "[UploadRequestFactory]: Failed to %@ because of no api secret provided.",
                    type: .info,
                    #function
                )
                throw NightscoutError.noAPISecret
            }
            guard !apiSecret.isEmpty else {
                LogController.log(
                    message: "[UploadRequestFactory]: Failed to %@ because of no api secret provided.",
                    type: .info,
                    #function
                )
                throw NightscoutError.noAPISecret
            }
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = createHeaders(apiSecret: apiSecret.sha1)
        } else {
            request.httpMethod = "GET"
        }
        
        return request
    }
    
    private func deleteTreatmentRequest() throws -> URLRequest? {
        LogController.log(message: "[UploadRequestFactory]: Try to %@.", type: .info, #function)
        guard let baseURLString = User.current.settings.nightscoutSync?.baseURL else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because no base url provided.",
                type: .info,
                #function
            )
            throw NightscoutError.invalidURL
        }
        guard let baseURL = URL(string: baseURLString) else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because of invalid base url.",
                type: .info,
                #function
            )
            throw NightscoutError.invalidURL
        }
        let url = baseURL.safeAppendingPathComponent("/api/v1/treatments")
        var request = URLRequest(url: url)
        
        guard let apiSecret = User.current.settings.nightscoutSync?.apiSecret else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because of no api secret provided.",
                type: .info,
                #function
            )
            throw NightscoutError.noAPISecret
        }
        guard !apiSecret.isEmpty else {
            LogController.log(
                message: "[UploadRequestFactory]: Failed to %@ because of no api secret provided.",
                type: .info,
                #function
            )
            throw NightscoutError.noAPISecret
        }
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = createHeaders(apiSecret: apiSecret.sha1)
        
        return request
    }
}

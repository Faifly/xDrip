//
//  URLSession+Logs.swift
//  xDrip
//
//  Created by Ivan Skoryk on 13.08.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import Foundation

extension URLSession {
    func loggableDataTask(with request: URLRequest) -> URLSessionDataTask {
        URLSession.log(request: request)
        return dataTask(with: request) { data, response, error in
            URLSession.log(data: data, response: response as? HTTPURLResponse, error: error)
        }
    }
    
    func loggableDataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        URLSession.log(request: request)
        return dataTask(with: request) { data, response, error in
            URLSession.log(data: data, response: response as? HTTPURLResponse, error: error)
            completionHandler(data, response, error)
        }
    }
    
    class func log(request: URLRequest) {
        let urlString = request.url?.absoluteString ?? ""
        let components = NSURLComponents(string: urlString)

        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"

        var requestLog = "--------------------------->\n"
        requestLog += "URL:\t\(urlString)"
        requestLog += "\n\n"
        requestLog += "Host:\t\(host)\n"
        requestLog += "\t\t\(method) \(path)?\(query)\n\n"
        
        requestLog += "[Request Headers]:\n"
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\t\(key): \(value)\n"
        }
        
        if let body = request.httpBody {
            requestLog += "\n[Request Body]:\n"
            if let bodyString = body.prettyPrintedJSONString {
                requestLog += "\(bodyString)\n"
            } else {
                requestLog += "Can't render body\n"
            }
        }

        requestLog += "\n--------------------------->[REQUEST END]"
        LogController.log(message: "[REQUEST]:\n\n%@", type: .debug, requestLog)
    }

    class func log(data: Data?, response: HTTPURLResponse?, error: Error?) {
        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")

        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"

        var responseLog = "<---------------------------\n"
        if let urlString = urlString {
            responseLog += "URL:\t\(urlString)"
            responseLog += "\n\n"
        }

        if let host = components?.host {
            responseLog += "Host:\t\(host)\n"
        }
        if let statusCode = response?.statusCode {
            responseLog += "\t\t\(path)?\(query)\nStatus Code: \(statusCode)\n\n"
        }
        
        responseLog += "[Response Headers]:\n"
        for (key, value) in response?.allHeaderFields ?? [:] {
            responseLog += "\t\(key):\t\(value)\n"
        }
        
        if let body = data {
            responseLog += "\n[Response Body]:\n"
            if let bodyString = body.prettyPrintedJSONString {
                responseLog += "\(bodyString)\n"
            } else {
                responseLog += "Can't render body\n"
            }
        }
        if let error = error {
            responseLog += "\n[Response Error]: \(error.localizedDescription)\n"
        }

        responseLog += "\n<---------------------------[RESPONSE END]"
        LogController.log(message: "[RESPONSE]:\n\n%@", type: .debug, responseLog)
    }
}

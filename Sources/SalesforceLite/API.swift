//
//  File.swift
//  
//
//  Created by PJ on 16/03/2023.
//

import Foundation

struct API {
    enum HTTPMethod {
        static let get = "GET"
        static let post = "POST"
    }
    
    private func headers(_ configuration: Configuration, _ userData: UserData) -> [String: String] {
        var headers: [String: String] = [:]
        headers["Content-Type"] = "application/json"
        headers["Authorization"] = "Bearer \(configuration.accessToken)"
        headers["X-SDK-Version"] = configuration.sdkVersion
        headers["User-Agent"] = "\(configuration.sdkName)/\(configuration.sdkVersion) (\(userData.os) \(userData.osVersion); \(userData.locale); \(userData.manufacturer)/\(userData.hardwareType) \(userData.bundleID)/\(userData.appVersion)"
        return headers
    }
    
    func appLaunch(_ configuration: Configuration, _ userData: UserData) {
        guard let url = URL(string: configuration.baseEndPoint + "/device/v1/\(configuration.etAppID)/sync/\(userData.deviceID)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        for header in headers(configuration, userData) {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        request.httpBody = "{}".data(using: .utf8)
        configuration.urlSession.dataTask(with: request) { _, _, error in
            if let error {
                print(error)
            }
        }.resume()
    }
    
    func appClose(event: TrackEvent, configuration: Configuration, userData: UserData, completionHandler: @escaping (Bool) -> Void) {
        guard let url = URL(string: configuration.baseEndPoint + "/device/v1/event/analytic") else {
            completionHandler(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        for header in headers(configuration, userData) {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
                
        request.httpBody = try? JSONEncoder().encode([event])
        configuration.urlSession.dataTask(with: request) { _, response, error in
            if let error {
                print(error)
            }
            guard let response = response as? HTTPURLResponse else {
                completionHandler(false)
                return
            }
            completionHandler(isValidResponse(response))
        }.resume()
    }
    
    func register(_ configuration: Configuration, userData: UserData, completionHandler: @escaping (Bool) -> Void) {
        guard let url = URL(string: configuration.baseEndPoint + "/device/v1/registration") else {
            completionHandler(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post
        for header in headers(configuration, userData) {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        let registration = Registration(configuration, userData: userData)
        
        request.httpBody = try? JSONEncoder().encode(registration)
        configuration.urlSession.dataTask(with: request) { _, response, error in
            if let error {
                print(error)
            }
            guard let response = response as? HTTPURLResponse else {
                completionHandler(false)
                return
            }
            completionHandler(isValidResponse(response))
        }.resume()
    }
    
    private func isValidResponse(_ response: HTTPURLResponse) -> Bool {
        (200..<300).contains(response.statusCode)
    }
}

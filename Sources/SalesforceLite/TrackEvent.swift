//
//  File.swift
//  
//
//  Created by pj on 17/03/2023.
//

import Foundation

struct TrackEvent: Codable {
    let value: Int
    let analyticTypes: [Int]
    let etAppID: String
    let deviceID: String
    let eventDate: String
    let requestID: String?
    let objectIDs: [String]?
    
    enum CodingKeys: String, CodingKey {
        case value
        case analyticTypes
        case etAppID = "etAppId"
        case deviceID = "deviceid"
        case eventDate
        case requestID = "requestId"
        case objectIDs = "objectIds"
    }
    
    init(_ configuration: Configuration, _ userData: UserData) {
        self.value = userData.secondsSinceLastLaunched()
        self.analyticTypes = userData.appOpenedFromPush ? [5] : [4]
        self.etAppID = configuration.etAppID
        self.deviceID = userData.deviceID
        self.eventDate = userData.timestamp()
        self.requestID = userData.pushRequestID
        if let objectID = userData.pushObjectID {
            self.objectIDs = [objectID]
        } else {
            self.objectIDs = nil
        }
    }
}

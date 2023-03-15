import Foundation

struct Registration: Codable {
    let sdkVersion: String
    let dst: Bool   // daylight saving time
    let deviceToken: String
    let locationEnabled: Bool
    let etAppID: String
    let platformVersion: String
    let quietPushEnabled: Bool
    let tags: [String]
    let locale: String
    let proximityEnabled: Bool
    let registrationDateUTC: String
    let registrationID: String
    let platform: String
    let timezone: String // is actually an offset from UTC I believe
    let hwid: String
    let attributes: [KeyValue]
    let pushEnabled: Bool
    let deviceID: String
    let appVersion: String
    
    enum CodingKeys: String, CodingKey {
        case sdkVersion = "sdk_Version"
        case dst = "dST"
        case deviceToken = "device_Token"
        case locationEnabled = "location_Enabled"
        case etAppID = "etAppId"
        case platformVersion = "platform_Version"
        case quietPushEnabled = "quietPushEnabled"
        case tags = "tags"
        case locale = "locale"
        case proximityEnabled = "proximity_Enabled"
        case registrationDateUTC = "registrationDateUtc"
        case registrationID = "registrationId"
        case platform = "platform"
        case timezone = "timezone"
        case hwid = "hwid"
        case attributes = "attributes"
        case pushEnabled = "push_Enabled"
        case deviceID = "deviceID"
        case appVersion = "app_Version"
    }
    
    init(_ configuration: Configuration, userData: UserData) {
        self.sdkVersion = configuration.sdkVersion
        self.dst = userData.daylightSavingsEnabled
        self.deviceToken = userData.deviceToken
        self.locationEnabled = false
        self.etAppID = configuration.etAppID
        self.platformVersion = userData.osVersion
        self.quietPushEnabled = false
        self.tags = userData.tags
        self.locale = userData.locale
        self.proximityEnabled = false
        self.registrationDateUTC = userData.timestamp()
        self.registrationID = userData.deviceID
        self.platform = userData.os
        self.timezone = userData.timezone
        self.hwid = userData.hardwareType
        self.attributes = userData.attributes.map { KeyValue(key: $0.key, value: $0.value) }
        self.pushEnabled = userData.pushEnabled
        self.deviceID = userData.deviceID
        self.appVersion = userData.appVersion
    }
    
    struct KeyValue: Codable {
        let key: String
        let value: String
    }
}

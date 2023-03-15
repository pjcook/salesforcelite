import UIKit

public struct UserData {
    internal let bundleID: String
    internal let appVersion: String
    internal let model: String
    internal let os: String
    internal let osVersion: String
    internal let hardwareType: String
    internal let manufacturer: String
    internal let userDefaults: UserDefaults
    internal let dateFormatter: DateFormatter
    internal var appOpenedFromPush: Bool = false
    internal var pushRequestID: String?
    internal var pushObjectID: String?
    
    internal var deviceID: String {
        if let deviceID = userDefaults.string(forKey: UserDefaultKeys.deviceID.rawValue) {
            return deviceID
        }
        
        let deviceID = UUID().uuidString
        userDefaults.set(deviceID, forKey: UserDefaultKeys.deviceID.rawValue)
        return deviceID
    }
    
    internal var deviceToken: String {
        get {
            userDefaults.string(forKey: UserDefaultKeys.deviceToken.rawValue) ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultKeys.deviceToken.rawValue)
        }
    }
    
    internal var pushEnabled: Bool {
        get {
            userDefaults.bool(forKey: UserDefaultKeys.pushEnabled.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultKeys.pushEnabled.rawValue)
        }
    }
    
    internal var appLastLaunched: Date? {
        get {
            let double = userDefaults.double(forKey: UserDefaultKeys.appLastLaunched.rawValue)
            guard double > 0 else { return nil }
            return Date(timeIntervalSince1970: double)
        }
        set {
            guard let newValue else {
                userDefaults.removeObject(forKey: UserDefaultKeys.appLastLaunched.rawValue)
                return
            }
            userDefaults.set(newValue.timeIntervalSince1970, forKey: UserDefaultKeys.appLastLaunched.rawValue)
        }
    }
    
    internal var pendingCloseEvent: TrackEvent? {
        get {
            guard let data = userDefaults.data(forKey: UserDefaultKeys.pendingCloseEvent.rawValue) else { return nil }
            return try? JSONDecoder().decode(TrackEvent.self, from: data)
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            userDefaults.set(data, forKey: UserDefaultKeys.pendingCloseEvent.rawValue)
        }
    }
    
    internal func secondsSinceLastLaunched() -> Int {
        Int(abs(appLastLaunched?.timeIntervalSinceNow ?? 0))
    }
    
    internal var locale: String {
        var languageCode = ""
        var regionCode = ""
        if #available(iOS 16, *) {
            languageCode = NSLocale.current.language.languageCode?.identifier ?? ""
            regionCode = NSLocale.current.region?.identifier ?? ""
        } else {
            languageCode = NSLocale.current.languageCode ?? ""
            regionCode = NSLocale.current.regionCode ?? ""
        }
        
        guard !languageCode.isEmpty, !regionCode.isEmpty else { return "unknown" }
        return "\(languageCode)_\(regionCode)"
    }
    
    public init(userDefaults: UserDefaults = .standard) {
        self.bundleID = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String) ?? ""
        self.appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        self.os = UIDevice.current.systemName
        self.osVersion = UIDevice.current.systemVersion
        self.model = UIDevice.current.model
        self.hardwareType = UIDevice.current.modelName
        self.manufacturer = "Apple"
        self.userDefaults = userDefaults
        
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    }
}

extension UserData {
    enum UserDefaultKeys: String {
        case deviceID = "com.salesforcelite.deviceID"
        case deviceToken = "com.salesforcelite.deviceToken"
        case appLastLaunched = "com.salesforcelite.appLastLaunched"
        case pendingCloseEvent = "com.salesforcelite.pendingCloseEvent"
        case attributes = "com.salesforcelite.attributes"
        case pushEnabled = "com.salesforcelite.pushEnabled"
        case tags = "com.salesforcelite.tags"
    }
}

extension UserData {
    internal func timestamp(date: Date = Date()) -> String {
        dateFormatter.string(from: date)
    }
    
    internal var timezone: String {
        String(TimeZone.current.secondsFromGMT() / 3600)
    }
    
    internal var daylightSavingsEnabled: Bool {
        TimeZone.current.isDaylightSavingTime(for: Date())
    }
    
    internal var attributes: [String: String] {
        get {
            userDefaults.object(forKey: UserDefaultKeys.attributes.rawValue) as? [String: String] ?? [:]
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultKeys.attributes.rawValue)
        }
    }
    
    internal var tags: [String] {
        get {
            userDefaults.object(forKey: UserDefaultKeys.tags.rawValue) as? [String] ?? []
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultKeys.tags.rawValue)
        }
    }
}

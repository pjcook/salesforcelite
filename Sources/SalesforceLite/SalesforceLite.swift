import UIKit

public final class SalesforceLite {
    private let configuration: Configuration
    private var userData: UserData
    private let api: API
    private var timer: Timer?
    private var hasChanges: Bool = false
    private var hasTrackedAppLaunch = false
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    public convenience init(configuration: Configuration) {
        self.init(configuration: configuration, api: API())
    }
    
    init(configuration: Configuration, api: API) {
        self.configuration = configuration
        self.userData = UserData(userDefaults: configuration.userDefaults)
        self.api = api
        listenForNotifications()
    }
    
    public func deviceIdentifier() -> String {
        userData.deviceID
    }
    
    public func attributes() -> [String: String] {
        userData.attributes
    }
    
    public func setAttributes(_ newAttributes: [String: String]) {
        var attributes = userData.attributes
        for (key, value) in newAttributes {
            attributes[key] = value
        }
        userData.attributes = attributes
        scheduleRegister()
    }
    
    public func setAttribute(key: String, value: String?) {
        var attributes = userData.attributes
        attributes[key] = value
        userData.attributes = attributes
        scheduleRegister()
    }
    
    public func tags() -> [String] {
        userData.tags
    }
    
    public func addTag(_ tag: String) {
        var tags = userData.tags
        tags.append(tag)
        userData.tags = tags
        scheduleRegister()
    }
    
    public func removeTag(_ tag: String) {
        var tags = userData.tags
        tags.removeAll(where: { $0 == tag })
        userData.tags = tags
        scheduleRegister()
    }
    
    public func setDeviceToken(_ deviceToken: Data) {
        userData.deviceToken = String(deviceToken: deviceToken)
        scheduleRegister()
    }
    
    public func setEnablePush(_ enabled: Bool) {
        userData.pushEnabled = enabled
        scheduleRegister()
    }
    
    public func setNotificationRequest(_ request: UNNotificationRequest) {
        let userInfo = request.content.userInfo
        userData.appOpenedFromPush = true
        userData.pushRequestID = userInfo["_r"] as? String
        userData.pushObjectID = userInfo["_m"] as? String
    }
}

extension SalesforceLite {
    @objc private func didBecomeActive() {
        // Some systems call `willEnterForegroundNotification` and `didFinishLaunchingNotification` but we don't want to double log
        guard hasTrackedAppLaunch == false else { return }
        hasTrackedAppLaunch = true
        
        // Log app starting timestamp
        userData.appLastLaunched = Date()
        
        // Reset app opened from push
        userData.appOpenedFromPush = false
        userData.pushRequestID = nil
        userData.pushObjectID = nil
        
        // Track launch event
        api.appLaunch(configuration, userData)
        checkForPendingAppClosedEvent()
    }
    
    @objc private func didEnterBackground() {
        // Reset to track next app launch
        hasTrackedAppLaunch = false
        
        // Start background task to give app closed event time to complete
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
        })
        
        self.appClose(event: TrackEvent(self.configuration, self.userData))
        self.register()
    }
    
    @objc private func willTerminate() {
        // Start background task to give app closed event time to complete
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
        })

        appClose(event: TrackEvent(configuration, userData))
    }
    
    private func checkForPendingAppClosedEvent() {
        guard let pendingCloseEvent = userData.pendingCloseEvent else { return }
        appClose(event: pendingCloseEvent)
    }
    
    private func appClose(event: TrackEvent) {
        userData.pendingCloseEvent = event
        api.appClose(event: event, configuration: configuration, userData: userData) { [weak self] completedSuccessfully in
            guard let self else { return }
            if completedSuccessfully {
                self.userData.pendingCloseEvent = nil
            }
            guard let identifier = self.backgroundTaskIdentifier else { return }
            UIApplication.shared.endBackgroundTask(identifier)
        }
    }
    
    // Fire after 5 seconds to allow other code to also manipulate the configuration to batch updates and reduce network calls
    private func scheduleRegister() {
        hasChanges = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] _ in
            guard let self else { return }
            self.register()
        })
    }
    
    private func register() {
        guard hasChanges else { return }
        hasChanges = false
        timer?.invalidate()
        timer = nil
        api.register(configuration, userData: userData) { [weak self] completedSuccessfully in
            guard let self else { return }
            self.hasChanges = !completedSuccessfully
        }
    }
    
    private func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didFinishLaunchingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: UIApplication.willTerminateNotification, object: nil)
    }
}

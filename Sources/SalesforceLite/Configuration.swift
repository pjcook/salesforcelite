import MachO
import UIKit

public struct Configuration {
    public let sdkVersion = "1.0.0"
    public let sdkName = "SalesForceLite"

    internal let etAppID: String
    internal let accessToken: String
    internal let baseEndPoint: String
    internal let mid: String
    internal let urlSession: URLSession
    internal let userDefaults: UserDefaults

    public init(etAppID: String, accessToken: String, baseEndPoint: String, mid: String, userDefaults: UserDefaults = .standard, urlSession: URLSession = .shared) {
        var base = baseEndPoint
        if base.hasSuffix("/") {
            base.removeLast()
        }
        self.etAppID = etAppID
        self.accessToken = accessToken
        self.baseEndPoint = base
        self.mid = mid
        self.userDefaults = userDefaults
        self.urlSession = urlSession
    }
}

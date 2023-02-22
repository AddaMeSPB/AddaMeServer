import Vapor
import URLRouting
import AddaSharedModels

public enum SiteRouterKey: StorageKey {
    public typealias Value = AnyParserPrinter<URLRequestData, SiteRoute>
}

extension Application {
    public var router: SiteRouterKey.Value {
        get {
            self.storage[SiteRouterKey.self]!
        }
        set {
            self.storage[SiteRouterKey.self] = newValue
        }
    }
}

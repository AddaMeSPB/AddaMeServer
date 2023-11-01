import Vapor
import MongoQueue

private struct MongoQueueStorageKey: StorageKey {
    public typealias Value = MongoQueue
}

extension Application {
    public var mongoQueue: MongoQueue {
        get {
            storage[MongoQueueStorageKey.self]!
        }
        set {
            storage[MongoQueueStorageKey.self] = newValue
        }
    }

    public func initializeMongoQueue() {
        self.mongoQueue = MongoQueue(collection: mongoDB["queue"])
    }
}


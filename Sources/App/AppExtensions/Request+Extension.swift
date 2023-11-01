//
//  Request+Extension.swift
//  
//
//  Created by Alif on 7/6/20.
//

import Vapor
import MongoKitten
import MongoQueue

extension Request {
    public var mongoDB: MongoDatabase {
        return application.mongoDB.hopped(to: eventLoop)
    }

    public var mongoQueue: MongoQueue {
        return application.mongoQueue
    }
}

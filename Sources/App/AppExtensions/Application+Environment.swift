//
//  File.swift
//  
//
//  Created by Saroar Khandoker on 16.08.2022.
//

import Vapor

extension Application {
    // configures your application
    public func setupDatabaseConnections(_ connectionString: inout String) {

        let environmentNameUppercased = environment.name.uppercased()

        switch environment {

        case .production:
            guard let mongoURL = Environment.get("MONGO_DB_\(environmentNameUppercased)_URL") else {
                fatalError("No MongoDB connection string is available in .env.production")
            }
            connectionString = mongoURL

        case .development:
            guard let mongoURL = Environment.get("MONGO_DB_\(environmentNameUppercased)_URL") else {
                fatalError("\(#line) No MongoDB connection string is available in .env.development")
            }
            connectionString = mongoURL
            self.logger.info("\(#line) mongoURL: \(connectionString)")

        case .staging:
            guard let mongoURL = Environment.get("MONGO_DB_\(environmentNameUppercased)_URL") else {
                fatalError("\(#line) No MongoDB connection string is available in .env.development")
            }
            connectionString = mongoURL
            self.logger.info("\(#line) mongoURL: \(connectionString)")

        case .testing:
            guard let mongoURL = Environment.get("MONGO_DB_\(environmentNameUppercased)_URL") else {
                fatalError("\(#line) No MongoDB connection string is available in .env.development")
            }
            connectionString = mongoURL
            self.logger.info("\(#line) mongoURL: \(connectionString)")

        default:
            guard let mongoURL = Environment.get("MONGO_DB_\(environmentNameUppercased)_URL") else {
                fatalError("No MongoDB connection string is available in .env.development")
            }
            connectionString = mongoURL
            self.logger.info("\(#line) mongoURL: \(connectionString)")
        }
    }

}

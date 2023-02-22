//
//  RoutesBuilder+Extension.swift
//  
//
//  Created by Alif on 7/6/20.
//

import Vapor

extension RoutesBuilder {
    @discardableResult
    public func postBigFile<Response>(
        _ path: PathComponent...,
        use closure: @escaping (Request) async throws -> Response
    ) -> Route
        where Response: AsyncResponseEncodable // ResponseEncodable
    {
        return self.on(.POST, path, body: .collect(maxSize: 50_000_000), use: closure)
    }

    @discardableResult
    public func postBigFile<Response>(
        _ path: [PathComponent],
        use closure: @escaping (Request) async throws -> Response
    ) -> Route
        where Response: AsyncResponseEncodable
    {
        return self.on(.POST, path, body: .collect(maxSize: 50_000_000), use: closure)
    }

    @discardableResult
    public func putBigFile<Response>(
        _ path: PathComponent...,
        use closure: @escaping (Request) async throws -> Response
    ) -> Route
        where Response: AsyncResponseEncodable
    {
        return self.on(.PUT, path, body: .collect(maxSize: 10_000_000), use: closure)
    }

    @discardableResult
    public func putBigFile<Response>(
        _ path: [PathComponent],
        use closure: @escaping (Request) async throws -> Response
    ) -> Route
        where Response: AsyncResponseEncodable
    {
        return self.on(.PUT, path, body: .collect(maxSize: 10_000_000), use: closure)
    }
}

//
//  File.swift
//  
//
//  Created by Saroar Khandoker on 29.11.2020.
//

import Vapor
import Fluent
import AddaSharedModels
import VaporRouting
import BSON

extension DeviceInOutPut: Content {}

public func devicesHandler(
    request: Request,
    route: DevicesRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case let .createOrUpdate(input: input):

        var currentUserID: ObjectId? = nil
        var newInput = DeviceInOutPut.init(
            name: input.name,
            pushToken: input.pushToken,
            voipToken: input.voipToken
        )

        /// we need it becz we add url for not login users
        if let token = request.accessToken {
            do {
                request.payload = try request.jwt.verify(Array(token.utf8), as: Payload.self)
            }
        }
        
        if request.loggedIn {
            currentUserID = request.payload.user.id
            newInput.ownerId = request.payload.user.id
        }
        newInput.ownerId = currentUserID
        
        let data = DeviceModel(
            identifierForVendor: newInput.identifierForVendor,
            name: newInput.name,
            model: newInput.model,
            osVersion: newInput.osVersion,
            pushToken: newInput.pushToken,
            voipToken: newInput.voipToken,
            userId: currentUserID
        )

        guard let device = try await DeviceModel.query(on: request.db)
            .filter(\.$pushToken == input.pushToken)
            .first()
            .get()

        else {
            try await data.save(on: request.db).get()
            return data.res
        }

        try await device.update(newInput)
        try await device.update(on: request.db)
        return device.res
        
    }
}

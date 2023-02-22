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
            token: input.token,
            voipToken: input.voipToken
        )
        
        if request.loggedIn {
            currentUserID = request.payload.user.id
            newInput.ownerId = request.payload.user.id
        }
        
        let data = DeviceModel(
            name: newInput.name,
            model: newInput.model,
            osVersion: newInput.osVersion,
            token: newInput.token,
            voipToken: newInput.voipToken,
            userId: currentUserID
        )
        
        let device = try await DeviceModel.query(on: request.db)
            .filter(\.$token == input.token)
            .first()
            .get()
        
        guard let device = device else {
            try await data.save(on: request.db).get()
            return data.res
        }
        
        try await device.update(newInput)
        try await device.update(on: request.db)
        return device.res
        
    }
}

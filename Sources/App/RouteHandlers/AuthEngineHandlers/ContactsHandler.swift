//
//  ContactsController.swift
//  
//
//  Created by Saroar Khandoker on 12.11.2020.
//

import Vapor
import AddaSharedModels
import Fluent
import BSON
import URLRouting

public func contactsHandler(
    request: Request,
    route: ContactsRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .getRegisterUsers(inputs: let phoneNumbers):
        if request.loggedIn == false { throw Abort(.unauthorized) }

        let user = try await UserModel.query(on: request.db)
          .with(\.$attachments)
          .filter(\.$phoneNumber ~~ phoneNumbers.mobileNumber)
          .all()
          .get()
          
          return user.map { $0.response }
    }
}

import Vapor
import Fluent
import VaporRouting
import AddaSharedModels
import BSON

public func conversationHandler(
    request: Request,
    usersId: String? = nil,
    conversationId: String,
    originalConversation: ConversationOutPut? = nil,
    route: ConversationRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .find:
        if request.loggedIn == false { throw Abort(.unauthorized) }
        guard let id = ObjectId(conversationId) else {
            throw Abort(.notFound, reason: "\(ConversationModel.schema)Id not found" )
        }
        
        let conversation = try await ConversationModel.query(on: request.db)
          .with(\.$admins) { $0.with(\.$attachments) }
          .with(\.$members) { $0.with(\.$attachments) }
          .filter(\.$id == id)
          .first()
          .unwrap(or: Abort(.notFound, reason: "Conversation not found by id \(ConversationModel.schema)Id") )
          .get()
        
        return conversation.response
        
    case .joinuser:
        if request.loggedIn == false { throw Abort(.unauthorized) }
        guard let conversationID = ObjectId(conversationId) else {
            throw Abort(.notFound, reason: "\(ConversationModel.schema)Id not found" )
        }

        guard let userID = request.payload.user.id else {
            throw Abort(.notFound, reason: "User not found!")
        }

//        guard
//            let userid = usersId,
//            let userID = ObjectId(userid) else {
//            throw Abort(.notFound, reason: "\(ConversationModel.schema)Id not found" )
//        }
        
        let conversation = try await ConversationModel.find(conversationID, on: request.db)
             .unwrap(or: Abort(.notFound, reason: "Cant find conversation") )
             .get()
           
        let user = try await UserModel.find(userID, on: request.db)
             .unwrap(or: Abort(.notFound, reason: "Cant find user") )
             .get()
        
        _ = try await conversation.$members.attach(user, method: .ifNotExists, on: request.db)
        
        return AddUser(conversationsId: conversationID, usersId: userID)

    case .messages(let messagesRoute):
        return try await messagesHandler(
            request: request,
            conversationId: conversationId,
            route: messagesRoute
        )        
    }
}

extension AddUser: Content {}

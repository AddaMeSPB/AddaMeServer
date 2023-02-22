import Vapor
import Fluent
import BSON
import AddaSharedModels

public func messagesHandler(
    request: Request,
    conversationId: String,
    route: MessagesRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .create(input: let input):
        if request.loggedIn == false { throw Abort(.unauthorized) }
        guard let currentUserID = request.payload.user.id else {
            throw Abort(.notFound, reason: "userId not found!")
        }

        let message = MessageModel(input, senderId: currentUserID)
        
        try await message
            .save(on: request.db)
            .get()
            
        return message.response
        
    case .list:
        if request.loggedIn == false { throw Abort(.unauthorized) }

        guard let id = ObjectId(conversationId) else {
            throw Abort(.notFound, reason: "\(ConversationModel.schema)Id not found")
        }

        let page = try await MessageModel.query(on: request.db)
            .with(\.$sender) {
                $0.with(\.$attachments)
            }
            .with(\.$recipient) {
                $0.with(\.$attachments)
            }
            .filter(\.$conversation.$id == id)
            .sort(\.$createdAt, .descending)
            .paginate(for: request)
            .get()

            return page.map { $0.response }
    case .find(id: let id, route: let messageRoute):
        return try await messageHandler(
            request: request,
            messageId: id,
            route: messageRoute
        )
    case .update(input: let input):
        if request.loggedIn == false { throw Abort(.unauthorized) }
        
        let message = input
        let id = message.id
        
        let item = try await MessageModel.query(on: request.db)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound, reason: "No Message found! by id: \(id)"))
            .get()
        
        item.id = message.id
        //item.messageBody = message.messageBody
        item._$id.exists = true
        try await item.update(on: request.db).get()
        return item.response
    case .delete(id: let messageId):
        if request.loggedIn == false { throw Abort(.unauthorized) }
        guard let currentUserID = request.payload.user.id else {
            throw Abort(.notFound, reason: "userId not found!")
        }
        
        guard let id = ObjectId(messageId) else {
            throw Abort(.notFound, reason: "Message can't delete becz id: \(messageId) is missing")
        }
        
        let message = try await MessageModel.find(id, on: request.db)
            .unwrap(or: Abort(.notFound, reason: "No Message found! by id: \(id)"))
            .get()
        
        guard let sender = message.sender else {
            throw Abort(.notFound, reason: "Unable to find Message sender ")
        }



        if currentUserID == sender.id {
            try await message.delete(on: request.db)
        } else {
            throw Abort(.unauthorized)
        }
        
        return HTTPStatus.ok
    }
}



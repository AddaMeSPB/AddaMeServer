import Vapor
import Fluent
import BSON
import AddaSharedModels

public func messageHandler(
    request: Request,
    messageId: String,
    route: MessageRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .find:
        if request.loggedIn == false { throw Abort(.unauthorized) }
        
        guard let id = ObjectId(messageId) else {
            throw Abort(.notFound, reason: "\(ConversationModel.schema)Id not found")
        }

        let message = try await MessageModel.query(on: request.db)
            .with(\.$sender) { $0.with(\.$attachments) }
            .with(\.$recipient) { $0.with(\.$attachments) }
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound, reason: "Message not found by id \(messageId)"))
            .get()
        
        return message.response
    }
}

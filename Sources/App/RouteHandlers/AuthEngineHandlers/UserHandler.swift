
import Vapor
import Fluent
import URLRouting
import AddaSharedModels
import BSON

public func userHandler(
    request: Request,
    usersId: String,
    route: UserRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .find:
        guard let id = ObjectId(usersId) else {
            throw Abort(.notFound, reason: "\(#line) parameters user id is missing")
        }
        
        guard let user = try await UserModel.query(on: request.db)
                .with(\.$attachments)
                .with(\.$events)
                .filter(\.$id == id)
                .first()
                .get()
        else { throw Abort(.notFound) }

        return user.mapGet()

    case .delete:
        guard let id = ObjectId(usersId)
        else {
            throw Abort(.notFound, reason: "\(#line) parameters user id is missing")
        }
        
        if request.payload.user.id != id {
            throw Abort(.unauthorized, reason: "\(#line) not authorized")
        }
        
        let user = try await UserModel.query(on: request.db)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound, reason: "\(#line) user not found!"))
            .get()
        
        do {
            
            try await ContactModel.query(on: request.db)
                .filter(\.$user.$id == id)
                .delete(force: true).get()
            
            try await DeviceModel.query(on: request.db)
                .filter(\.$user.$id == id)
                .delete(force: true).get()
            
            try await HangoutEventModel.query(on: request.db)
                .filter(\.$owner.$id == id)
                .delete(force: true).get()
            
            try await AttachmentModel.query(on: request.db)
                .filter(\.$user.$id == id)
                .delete(force: true).get()
            
            try await MessageModel.query(on: request.db)
                .filter(\.$sender.$id == id)
                .delete(force: true).get()
            
            let userWithConversation = try await UserModel.query(on: request.db)
                .with(\.$adminConversations) {
                    $0.with(\.$admins)
                }
                .filter(\.$id == id)
                .first()
                .unwrap(or: Abort(.notFound, reason: "\(#line) user not found!"))
                .get()
            
            for auc in userWithConversation.adminConversations {
                guard let aucid = auc.id else {
                    throw Abort(.notFound, reason: "\(#line) parameters conversation id is missing")
                }
                
                do {
                    let uConversations = try await UserConversationModel.query(on: request.db)
                        .filter(\.$conversation.$id == aucid)
                        .all().get()
                    
                    for uc in uConversations {
                         try await uc.delete(force: true, on: request.db).get()
                    }
                    
                    try await auc.delete(force: true, on: request.db).get()
                    
                } catch {
                    throw Abort(.expectationFailed, reason: "\(#line) cant delete \(error)")
                }
            }
            
            try await user.delete(force: true, on: request.db).get()
            
        } catch {
            throw Abort(.expectationFailed, reason: "\(#line) cant delete \(error)")
        }
        
        return HTTPStatus.ok
        
    case .deleteSoft:
        guard let id = ObjectId(usersId)
        else {
            throw Abort(.notFound, reason: "\(#line) parameters user id is missing")
        }
        
        if request.payload.user.id != id {
            throw Abort(.unauthorized, reason: "\(#line) not authorized")
        }
        
        let user = try await UserModel.query(on: request.db)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound, reason: "\(#line) user not found!"))
            .get()
        
        do {
            try await ContactModel.query(on: request.db)
                .filter(\.$user.$id == id)
                .delete().get()
            
            try await DeviceModel.query(on: request.db)
                .filter(\.$user.$id == id)
                .delete().get()
            
            try await HangoutEventModel.query(on: request.db)
                .filter(\.$owner.$id == id)
                .delete().get()
            
            try await AttachmentModel.query(on: request.db)
                .filter(\.$user.$id == id)
                .delete().get()
            
            try await MessageModel.query(on: request.db)
                .filter(\.$sender.$id == id)
                .delete().get()
            
            let uConversationAdmin = try await UserConversationModel.query(on: request.db)
                .filter(\.$admin.$id == id)
                .first()
                .unwrap(or: Abort(.notFound, reason: "\(#line) UserConversation not found with id: \(id)"))
                .get()
           
            let uConversationMember = try await UserConversationModel.query(on: request.db)
                .filter(\.$member.$id == id)
                .first()
                .unwrap(or: Abort(.notFound, reason: "\(#line) UserConversation not found with id: \(id)"))
                .get()
            
            // i have to remove all userconversation from which conversation was deleted
            try await uConversationAdmin.$conversation.query(on: request.db).delete().get()
            try await uConversationMember.$conversation.query(on: request.db).delete().get()
            
            try await uConversationAdmin.delete(on: request.db).get()
            try await uConversationMember.delete(on: request.db).get()
            
            try await user.delete(on: request.db).get()
        } catch {
            throw Abort(.expectationFailed, reason: "\(#line) cant delete \(error)")
        }
        
        return HTTPStatus.ok
        
    case .restore:
        
        guard let id = ObjectId(usersId) else {
            throw Abort(.notFound, reason: "\(#line) parameters user id is missing")
        }
        
        if request.payload.user.id != id {
            throw Abort(.unauthorized, reason: "\(#line) not authorized")
        }
        
        do {
            let user = try await UserModel.query(on: request.db)
                .withDeleted()
                .filter(\.$id == id)
                .first()
                .unwrap(or: Abort(.notFound, reason: "\(#line) cant find before restore User id: \(id) "))
                .get()
            
            try await user.restore(on: request.db)
            
            try await HangoutEventModel.query(on: request.db)
                .withDeleted()
                .filter(\.$owner.$id == id)
                .set(\.$deletedAt, to: nil)
                .update().get()
            
            try await ContactModel.query(on: request.db)
                .withDeleted()
                .filter(\.$user.$id == id)
                .set(\.$deletedAt, to: nil)
                .update().get()
            
            try await DeviceModel.query(on: request.db)
                .withDeleted()
                .filter(\.$user.$id == id)
                .set(\.$deletedAt, to: nil)
                .update().get()
            
            try await HangoutEventModel.query(on: request.db)
                .withDeleted()
                .filter(\.$owner.$id == id)
                .set(\.$deletedAt, to: nil)
                .update().get()
            
            try await MessageModel.query(on: request.db)
                .filter(\.$sender.$id == id)
                .set(\.$deletedAt, to: nil)
                .withDeleted()
                .update().get()
                            
            try await AttachmentModel.query(on: request.db)
                .withDeleted()
                .filter(\.$user.$id == id)
                .set(\.$deletedAt, to: nil)
                .update().get()
            
            // UserConerversations Restore
            try? await UserConversationModel
                .query(on: request.db)
                .with(\.$conversation)
                .withDeleted()
                .filter(\.$admin.$id == id)
                .set(\.$deletedAt, to: nil)
                .update().get()
            
            try? await UserConversationModel
                .query(on: request.db)
                .with(\.$conversation)
                .withDeleted()
                .filter(\.$member.$id == id)
                .set(\.$deletedAt, to: nil)
                .update().get()
            
            // Conversations
            let adminConversations = try await ConversationModel.query(on: request.db)
                .withDeleted()
                .join(siblings: \.$admins)
                .filter(UserModel.self, \.$id == id)
                .all()
            
            for conversation in adminConversations {
                if let acid = conversation.id {
                    try await ConversationModel
                        .query(on: request.db)
                        .filter(\.$id == acid)
                        .set(\.$deletedAt, to: nil)
                        .withDeleted()
                        .update()
                        .get()
                }
            }
            
            // this part i dont think i need it
//            let memberConversations = try await Conversation.query(on: request.db)
//                .withDeleted()
//                .join(siblings: \.$members)
//                .filter(User.self, \.$id == id)
//                .all()
//
//            for conversation in memberConversations {
//                if let mcid = conversation.id {
//                    try await Conversation
//                        .query(on: request.db)
//                        .filter(\.$id == mcid)
//                        .set(\.$deletedAt, to: nil)
//                        .withDeleted()
//                        .update()
//                        .get()
//                }
//            }

        } catch {
            throw Abort(.expectationFailed, reason: "\(#line) cant delete \(error)")
        }
        
        let user = try await UserModel.query(on: request.db)
            .with(\.$attachments)
            .with(\.$events)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound, reason: "\(#line) After restore user cant find user"))
            .get()
            
        return user.response
    case let .devices(devicesRoute):
        return try await devicesHandler(request: request, route: devicesRoute)
    case let .attachments(attachmentsRoute):
        return try await attachmentsHandler(request: request, route: attachmentsRoute)
    case let .conversations(conversationsRoute):
        return try await conversationsHandler(
            request: request,
            usersId: usersId,
            route: conversationsRoute
        )
    case .events(_):
        return Response(status: .badRequest)
    }
}

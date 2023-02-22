import Vapor
import Fluent
import VaporRouting
import AddaSharedModels
import BSON

public func conversationsHandler(
    request: Request,
    usersId: String? = nil,
    route: ConversationsRoute
) async throws -> AsyncResponseEncodable {
    switch route {
    case .create(input: let input):
        if request.loggedIn == false { throw Abort(.unauthorized) }
        
        let content = input
        guard let currentUserID = request.payload.user.id else {
            throw Abort(.notFound, reason: "userId not found!")
        }

        let conversation = ConversationModel(title: content.title, type: content.type)
        
        guard let currentUser = try await UserModel.query(on: request.db)
                .with(\.$attachments)
                .filter(\.$id == currentUserID)
                .first().get()
            else {
                throw Abort(.notFound, reason: "Cant find admin user from id: \(currentUserID)")
            }
        
        
        guard
            let opponentUser = try await UserModel.query(on: request.db)
                .with(\.$attachments)
                .filter(\.$phoneNumber == content.opponentPhoneNumber)
                .first().get()
            else {
                throw Abort(.notFound, reason: "Cant find member user by phoneNumber: \(content.opponentPhoneNumber) or current user and member user cant be same")
            }
        
        guard let opponentUserId = opponentUser.id
            else {
                throw Abort(.notFound, reason: "Cant find opponentUserId")
            }
        debugPrint("opponentUserId \(opponentUserId)")
        
        let userConversation = try await UserConversationModel.query(on: request.db)
                .filter(\.$member.$id == currentUserID)
                .filter(\.$member.$id == opponentUserId)
                .join(ConversationModel.self, on: \UserConversationModel.$conversation.$id == \ConversationModel.$id)
                .filter(ConversationModel.self, \ConversationModel.$type == .oneToOne)
                .with(\.$conversation)
                .all().get()
        
        if userConversation.count > 0 {

            guard let uconversation = userConversation.last,
                  let conversationID = uconversation.conversation.id
            else {
                throw Abort(.notFound, reason: "Cant find admin user from id: \(currentUserID)")
            }
            
            let conversationOldResponse =  try await ConversationModel.query(on: request.db)
              .with(\.$admins) {
                  $0.with(\.$attachments)
              }
              .with(\.$members) {
                  $0.with(\.$attachments)
              }
              .with(\.$messages) { // this must be remove
                $0.with(\.$sender)
                  {
                      $0.with(\.$attachments)
                  }
                  .with(\.$recipient)
                  {
                      $0.with(\.$attachments)
                  }
              }
              .filter(\.$id == conversationID)
              .first()
              .unwrap(or: Abort(.notFound, reason: "Conversation not found by id \(conversationID)"))
              .get()
            
            guard let conversationID = conversationOldResponse.id
            else {
                throw Abort(.notFound, reason: "Cant find conversationID: \(conversationOldResponse)")
            }
            
            let admins = conversationOldResponse.admins.map { $0.response }
            let members = conversationOldResponse.members.map { $0.response }
            
            let title = conversation.type == .oneToOne
            ? opponentUser.response.fullName ?? "missing"
            : conversation.title

            let lastMessage = conversationOldResponse.messages
                .sorted(by: {$0.createdAt!.timeIntervalSince1970 < $1.createdAt!.timeIntervalSince1970})
                .map { $0.response }.last
            
            return ConversationOutPut(
                id: conversationID,
                title: title ,
                type: conversation.type,
                admins: admins,
                members: members,
                lastMessage: lastMessage,
                createdAt: conversation.createdAt ?? Date(),
                updatedAt: conversation.deletedAt ?? Date(),
                deletedAt: conversation.deletedAt
            )

        }
        
        _ = try await conversation.save(on: request.db)
        _ = try await conversation.$admins.attach(currentUser, method: .ifNotExists, on: request.db)
        _ = try await conversation.$members.attach(currentUser, method: .ifNotExists, on: request.db)
        _ = try await conversation.$members.attach(opponentUser, method: .ifNotExists, on: request.db)
        
        
        guard let conversationID = conversation.id
        else {
            throw Abort(.notFound, reason: "Cant find conversationID: \(conversation)")
        }

        let conversationResponse = try await ConversationModel.query(on: request.db)
          .with(\.$admins) {
              $0.with(\.$attachments)
          }
          .with(\.$members) {
              $0.with(\.$attachments)
          }
          .with(\.$messages) {
            $0.with(\.$sender)
              {
                  $0.with(\.$attachments)
              }
              .with(\.$recipient)
              {
                  $0.with(\.$attachments)
              }
          }
          .filter(\.$id == conversationID)
          .first()
          .unwrap(or: Abort(.notFound, reason: "Conversation not found by id \(conversationID)"))
          .get()
        
        let admins = conversationResponse.admins.map { $0.response }
        let members = conversationResponse.members.map { $0.response }
        let title = conversation.type == .oneToOne
        ? opponentUser.response.fullName ?? "missing"
        : conversation.title

        let lastMessage = conversationResponse.messages
            .sorted(by: {$0.createdAt!.timeIntervalSince1970 < $1.createdAt!.timeIntervalSince1970})
            .map { $0.response }.last
        
        return ConversationOutPut(
            id: conversation.id!,
            title: title,
            type: conversation.type,
            admins: admins,
            members: members,
            lastMessage: lastMessage,
            createdAt: conversation.createdAt ?? Date(),
            updatedAt: conversation.deletedAt ?? Date(),
            deletedAt: conversation.deletedAt
        )

    case .list:
        if request.loggedIn == false { throw Abort(.unauthorized) }
        guard let currentUserID = request.payload.user.id else {
            throw Abort(.notFound, reason: "userId not found!")
        }
        
        let page =  try await UserConversationModel.query(on: request.db)
          .with(\.$member)
          .with(\.$conversation) {
              $0.with(\.$members) {
                  $0.with(\.$attachments)
              }
              $0.with(\.$messages) {
                $0.with(\.$sender) { $0.with(\.$attachments) }
                $0.with(\.$recipient) { $0.with(\.$attachments) }
            }
          }
          .filter( \.$member.$id == currentUserID)
          .paginate(for: request)
          .get()
          
         return page.map { userConversation -> ConversationOutPut in
              let conversation = userConversation.conversation
              let adminsResponse = conversation.$admins.value.map { $0.map { u in u.response } }
              let membersResponse = conversation.members.map { $0.response } // .filter { $0.id == id }
              let messageLastResponse = conversation.messages.sorted(by: { $0.createdAt?.compare($1.createdAt ?? Date()) == .orderedAscending })
                 //.sorted(by: {$0.createdAt!.timeIntervalSince1970 < $1.createdAt!.timeIntervalSince1970})
                 .map { $0.response }.last
              
             let conversationOneToOneTitle = membersResponse.first(where: { $0.id != currentUserID })?.fullName ?? "Deleted Account"

             let title = conversation.type == .oneToOne ? conversationOneToOneTitle : conversation.title
             
              return ConversationOutPut(
                  id: conversation.id!,
                  title: title,
                  type: conversation.type,
                  admins: adminsResponse,
                  members: membersResponse,
                  lastMessage: messageLastResponse,
                  createdAt: conversation.createdAt!,
                  updatedAt: conversation.updatedAt!
              )
          }

    case let .conversation(id: id, route: conversationRoute):
        return try await conversationHandler(
            request: request,
            usersId: usersId,
            conversationId: id,
            route: conversationRoute
        )
    case let .update(input: input):
        if request.loggedIn == false { throw Abort(.unauthorized) }
        
        let conversationDecode = input
        
        let id = conversationDecode.id
        
        guard let admins = conversationDecode.admins else {
            throw Abort(.notFound, reason: "This Conversation dont have admins, conversastion \(id)")
        }

        guard let currentUserID = request.payload.user.id else {
            throw Abort(.notFound, reason: "userId not found!")
        }
        
        if !admins.map({ $0.id }).contains(currentUserID)
        {
            throw Abort(.notFound,reason: "Dont have permission to change this Conversation")
        }
        
        // only owner can update
        let conversation =  try await ConversationModel.query(on: request.db)
          .filter(\.$id == id)
          .first()
          .unwrap(or: Abort(.notFound, reason: "No Conversation. found! by id: \(id)"))
          .get()
          
        conversation.id = conversation.id
        conversation._$id.exists = true
        try await conversation.update(on: request.db)
        return conversation

    case let .delete(id: conversationId):
        if request.loggedIn == false { throw Abort(.unauthorized) }
        
        guard let id = ObjectId(conversationId) else {
          throw Abort(.notFound, reason: "No Conversation. found! for delete by id")
        }
        
        let conversation = try await ConversationModel.find(id, on: request.db)
          .unwrap(or: Abort(.notFound, reason: "No Conversation. found! by id: \(id)"))
          .get()

        guard let currentUserID = request.payload.user.id else {
            throw Abort(.notFound, reason: "userId not found!")
        }

          
        if conversation.admins.map({ $0.id }).contains(currentUserID) != false {
          throw Abort(.unauthorized)
        } else {
          try await conversation.delete(on: request.db)
        }
          
        return HTTPStatus.ok
    }
}


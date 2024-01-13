//
//  ChatClient.swift
//  
//
//  Created by Saroar Khandoker on 30.09.2020.
//

import Vapor
import MongoKitten
import Fluent
import AddaSharedModels
import APNS

actor WebsocketClients {
    private var allSockets: [ObjectId: WebSocket] = [:]
    private let logger = Logger(label: "WebsocketClients")

    func activeSockets(senderId: ObjectId) -> [WebSocket] {
        let allExceptSender = allSockets.filter { $0.key != senderId }
        return allExceptSender.values.filter { !$0.isClosed }
    }

    func join(id: ObjectId, on ws: WebSocket) {
        self.allSockets[id] = ws
    }

    func find(id: ObjectId) -> WebSocket? {
        return self.allSockets[id]
    }

    func leave(id: ObjectId) {
        self.allSockets.removeValue(forKey: id)
    }

    func send(msg: MessageItem, req: Request) async throws {
        guard let senderID = req.payload.user.id else {
            throw Abort(.notFound, reason: "current User missing from payload")
        }

        let messageCreate = MessageModel(msg, senderId: senderID, receipientId: nil)

        do {
            try await messageCreate.save(on: req.db)

            for socket in activeSockets(senderId: senderID) {
                try await send(message: messageCreate, req: req, socket: socket)
            }

            try await sendNotificationToConversationMembers(
                msgItem: msg,
                senderID: senderID,
                with: req
            )

        } catch {
            messageCreate.isDelivered = false
            print("Send Msg to User: \(senderID) error: \(error)")
            throw Abort(.notFound, reason: "Send Msg to User: \(senderID) error: \(error)")
        }

    }

    @Sendable 
    func send(message: MessageModel, req: Request, socket: WebSocket) async throws {
        if !req.loggedIn {
            logger.error("\(#line) Unauthorized send message")
            throw Abort(.unauthorized)
        }

        try await MessageModel.query(on: req.db)
            .with(\.$sender) { $0.with(\.$attachments) }
            .with(\.$recipient) { $0.with(\.$attachments) }
            .filter(\.$id == message.id!)
            .first()
            .unwrap(or: Abort(.notFound, reason: "No Message found! by id: \(message.id?.hexString ?? "")"))
            .map { original in
                let message = ChatOutGoingEvent.message(original.response).jsonString
                let lastMessage = ChatOutGoingEvent.conversation(original.response).jsonString

                socket.send(message ?? "")
                socket.send(lastMessage ?? "")
            }
            .get()
    }

    @Sendable 
    private func sendNotificationToConversationMembers(
        msgItem: MessageItem,
        senderID: ObjectId,
        with req: Request
    )  async throws {

        guard let conversation = try await ConversationModel.query(on: req.db)
            .with(\.$members)
            .filter(\.$id == msgItem.conversationId)
            .first()
            .get()

        else {
            throw Abort(.notFound, reason: "No Conversation found! by ID \(msgItem.conversationId.hexString)")
        }

        for member in conversation.members where member.id != senderID {

            guard let memberID = member.id else {
                throw Abort(.notFound, reason: "current User missing from payload")
            }

            guard let device = try await DeviceModel.query(on: req.db)
                .filter(\.$user.$id == memberID)
                .first()
                .get()

            else {
                continue
//                throw Abort(.notFound, reason: "User not found from \(#function)")
            }

            try await req.apns.send(
                .init(
                    title: conversation.title,
                    subtitle: msgItem.messageBody
                ),
                to: device.pushToken
            ).get()

        }
      }

}

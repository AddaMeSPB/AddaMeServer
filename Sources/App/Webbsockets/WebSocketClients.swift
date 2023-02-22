//
//  WebsocketClients.swift
//  
//
//  Created by Alif on 19/6/20.
//

import Vapor
import MongoKitten
import AddaSharedModels
import NIOConcurrencyHelpers

final class WebsocketClients {
    
    let lock: NIOLock
    var eventLoop: EventLoop
    var allCliendts: [ObjectId: WebSocketClient]
    let logger: Logger
    
    var activeClients: [WebSocketClient] {
        self.lock.withLock {
            self.allCliendts.values.filter { !$0.socket.isClosed }
        }
    }
    
    init(eventLoop: EventLoop, clients: [ObjectId: WebSocketClient] = [:]) {
        self.eventLoop = eventLoop
        self.allCliendts = clients
        self.logger = Logger(label: "WebsocketClients")
        self.lock = NIOLock()
    }
    
    func add(_ client: WebSocketClient) {
        self.lock.withLock {
            self.allCliendts[client.id] = client
        }
    }
    
    func remove(_ client: WebSocketClient) {
        self.lock.withLock {
            self.allCliendts[client.id] = nil
        }
    }
    
    func find(_ objectId: ObjectId) -> WebSocketClient? {
        self.lock.withLock {
            return self.allCliendts[objectId]
        }
    }
    
  fileprivate func sendNotificationToConversationMembers(_ msg: MessageModel, _ req: Request) -> EventLoopFuture<()> {
    return msg.$conversation.query(on: req.db)
      .with(\.$members) {
        $0.with(\.$devices) {
            $0.with(\.$user) { $0.with(\.$attachments) }
        }
      }
      .first()
      .unwrap(or: Abort(.noContent) )
      .map { conversation in
          for user in conversation.members where user.id != req.payload.user.id {
          for device in user.devices {
          req.apns.send(
            .init(title: conversation.title, subtitle: msg.messageBody),
            to: device.token
          )
        }
      }
    }
  }
  
  func send(_ msg: MessageItem, req: Request) {
        
      let messageCreate = MessageModel(msg, senderId: req.payload.user.id, receipientId: nil)
        
        req.db.withConnection { _ in
            messageCreate.save(on: req.db)
        }.whenComplete { [self] res in
            
            let success: Bool
            
            switch res {
            case .failure(let err):
                self.logger.report(error: err)
                success = false
                
            case .success:
                self.logger.info("success true")
                success = true
            }
            
            messageCreate.isDelivered = success
            _ = messageCreate.update(on: req.db)
            
            let chatClients = self.activeClients.compactMap { $0 as? ChatClient }
            
            for client in chatClients where client.id != msg.sender!.id {
                client.send(messageCreate, req)
            }
          
           _ = sendNotificationToConversationMembers(messageCreate, req)
        }
        
    }
    
    deinit {
        let futures = self.allCliendts.values.map { $0.socket.close() }
        try! self.eventLoop.flatten(futures).wait()
        logger.debug("deinit call from WebsocketClients")
    }
    
}


//
//  File.swift
//  
//
//  Created by Saroar Khandoker on 19.10.2020.
//

import Vapor
import Fluent
import MongoKitten
import AddaSharedModels
import NIOConcurrencyHelpers

//class WebSocketController {
//    let lock: NIOLock
//    let db: Database
//    let logger: Logger
//    var chatClients: WebsocketClients
//    
//    init(eventLoop: EventLoop, db: Database) {
//        self.lock = NIOLock()
//        self.db = db
//        self.logger = Logger(label: "WebSocketController")
//        self.chatClients = WebsocketClients(eventLoop: eventLoop)
//    }
//
//    func connect(_ ws: WebSocket, req: Request) {
//        
//        ws.onPong { ws in
//            ws.onText { (ws, text) in
//                print(#line, text)
//            }
//        }
//        
//        ws.onPong { ws in
//            ws.onText { (ws, text) in
//                print(#line, text)
//            }
//        }
//        
//        ws.onText { [self] ws, text in
//            guard let data = text.data(using: .utf8) else {
//                logger.error( "Wrong encoding for received message")
//                return
//            }
//            
//            let string = String(data: data, encoding: .utf8)
//            print(#line, string as Any)
//            
//            let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data)
//            
//            switch chatOutGoingEvent {
//            
//            // from client to server
//            case .connect(let user):
//                let userID = user.id
//                let client = ChatClient(id: userID, socket: ws)
//                chatClients.add(client)
//            
//            // from client to server
//            case .disconnect(let user):
//                let userID = user.id 
//                let client = ChatClient(id: userID, socket: ws)
//                chatClients.remove(client)
//
//            // from client to server & server to client
//            case .message(let msg):
//                print(#line, msg)
//                chatClients.send(msg, req: req)
//                
//            // from server to client
//            case .conversation(let lastMessage):
//                print(#line, lastMessage)
//                chatClients.send(lastMessage, req: req)
//                
//            case .notice(let msg):
//                print(#line, msg)
//                
//            case .error(let error):
//                print(#line, error)
//                logger.error("(error)")
//            case .none:
//                print(#line, "decode error")
//            }
//        }
//    }
//}

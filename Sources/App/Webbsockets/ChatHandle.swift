//
//  ChatHandle.swift
//  
//
//  Created by Alif on 19/6/20.
//

import Vapor
import Foundation
import MongoKitten
import AddaSharedModels

actor WebsocketHandle {

    private var wsClients: WebsocketClients

    init(wsClients: WebsocketClients) {
        self.wsClients = wsClients
    }

    func connectionHandler(ws: WebSocket, req: Request) {

//        ws.onPing { ws in
//            ws.onText { (ws, text) in
//                print(#line, text)
//            }
//        }
        req.eventLoop.execute {
            ws.onText { [self] ws, text in
                guard let data = text.data(using: .utf8) else {
                    req.logger.error("Wrong encoding for received message for connect web socket")
                    return
                }
                
                let string = String(data: data, encoding: .utf8)
                req.logger.info("\(#function) \(#line) \(string as Any)")
                
                guard let chatOutGoingEvent = ChatOutGoingEvent.decode(data: data) else {
                    
                    req.logger.notice("unacceptableData for connect web socket")
                    Task {
                        try await ws.close(code: .unacceptableData)
                    }
                    return
                }
                
                let user = req.payload.user
                guard let userID = user.id else {
                    req.logger.error("Cant found user from req.payload")
                    return
                }
                
                switch chatOutGoingEvent {
                    case .connect:
                        
                        Task {
                            await wsClients.join(id: userID, on: ws)
                        }
                        req.logger.info("web socker connect for user \(user.email ?? user.fullName ?? "")")
                        
                    case .disconnect:
                        
                        Task {
                            await wsClients.leave(id: userID)
                        }
                        req.logger.info("web socker remove for user \(user.email ?? user.fullName ?? "")")
                        
                    case .message(let msg):
                        
                        Task {
                            try await wsClients.send(msg: msg, req: req)
                        }
                        
                    case .conversation(let lastMessage):
                        
                        Task {
                            try await wsClients.send(msg: lastMessage, req: req)
                        }
                        
                        req.logger.info("conversation conversation: \(lastMessage)")
                        
                    case .notice(let msg):
                        req.logger.info("error: \(msg)")
                    case .error(let error):
                        req.logger.error("error: \(error.localizedDescription)")
                }
            }
        }
    }
    
}

struct WebsocketMessage<T: Codable>: Codable {
    var client: UUID = UUID()
    let data: T
}

extension Data {
    func decodeWebsocketMessage<T: Codable>(_ type: T.Type) -> WebsocketMessage<T>? {
        try? JSONDecoder().decode(WebsocketMessage<T>.self, from: self)
    }
}


//"{"type":"connect","conversation":{"id":"5f78851afd41fde755669cc0","title":"Cool","creator":{"id":"5f78851afd41fde755669cc0","firstName":"Alif","phoneNumber":"+79218821218"},"members":[{"id":"5f78851afd41fde755669cc0","firstName":"Alif","phoneNumber":"+79218821218"}]}}"


//{"type":"message","message":{"id":"5f78851afd41fde755669cc0","sender":{"id":"5f78826c156076f971b25e7b","firstName":"Alif","phoneNumber":"+79218821218"},"messageBody":"Hello there","messageType":"text","conversationId":"5f78851afd41fde755669cc0","isRead":false}}


//{ "type": "connect",
//    "user": {
//        "id":"5f78851afd41fde755669cc0",
//        "title": "Testing",
//        "updated_at": "2020-10-03T14:05:14Z",
//        "creator": {
//            "_id": "5f78826c156076f971b25e7b",
//            "updated_at": "2020-10-03T13:53:48Z",
//            "phone_number": "+79218821218",
//            "created_at": "2020-10-03T13:53:48Z"
//        },
//        "members":[{
//            "_id":"5f78826c156076f971b25e7b",
//            "updated_at":"2020-10-03T13:53:48Z",
//            "phone_number":"+79218821218",
//            "created_at":"2020-10-03T13:53:48Z"
//        }],
//        "created_at":"2020-10-03T14:05:14Z"
//    }
//
//}

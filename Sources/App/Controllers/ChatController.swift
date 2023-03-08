//
//  File.swift
//  
//
//  Created by Saroar Khandoker on 19.10.2020.
//

import Vapor
import Fluent
import MongoKitten
import JWT
import AddaSharedModels

extension WebsocketController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.webSocket(onUpgrade: self.webSocket)
    }
}

struct WebsocketController {
    let wsController: WebsocketHandle

    func webSocket(_ req: Request, ws: WebSocket) {
        Task {
            await self.wsController.connectionHandler(ws: ws, req: req)
        }
    }
}

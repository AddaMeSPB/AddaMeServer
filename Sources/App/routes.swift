import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    try app.group("v1") { api in
        let chat = api.grouped("chat")
        let webSocketController = WebSocketController(eventLoop: app.eventLoopGroup.next(), db: app.db)
        try chat.register(collection: ChatController(wsController: webSocketController) )

        try api.register(collection: AuthController())
    }
}

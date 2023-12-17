import Fluent
import Vapor

func routes(_ app: Application) throws {

    app.get { req in
        try await req.view.render("index")
    }
    
//    try app.group("v1") { api in
//        let chat = api.grouped("chat")
//        let webSocketController = WebsocketHandle.init(wsClients: .init())
//        try chat.register(collection: WebsocketController(wsController: webSocketController) )
//    }

    // Grouping API version v1
    try app.group("v1") { api in
        // Grouping chat
        let chat = api.grouped("chat")

        // Initialize WebsocketHandle
        let wsClients = WebsocketClients()  // Assuming this is your WebSocket clients manager
        let webSocketHandle = WebsocketHandle(wsClients: wsClients)

        // Initialize and register WebsocketController
        let webSocketController = WebsocketController(wsController: webSocketHandle)
        try chat.register(collection: webSocketController)
    }
}
